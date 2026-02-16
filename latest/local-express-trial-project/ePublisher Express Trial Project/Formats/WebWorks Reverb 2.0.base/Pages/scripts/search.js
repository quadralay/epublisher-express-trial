// Copyright (c) 2010-2025 Quadralay Corporation.  All rights reserved.
//
// ePublisher 2025.1
//

// IMPORTANT: global variables are modified by search.xsl and should not be changed.
var GLOBAL_MINIMUM_WORD_LENGTH = 0;
var GLOBAL_STOP_WORDS_ARRAY = 'and or'.split(' ');
var GLOBAL_NO_SEARCH_RESULTS_CONTAINER_HTML = '<div>No results for you!</div>';
var GLOBAL_GENERATION_HASH = '';

// Search
//
var Search = {
  'window': window,
  'control': undefined,
  'loading': false,
  'query': '',
  'connect_info': null,
  'group_titles': {},
  'executing': false,
  'cancel': false,
  'ready': false
};

Search.KnownParcelURL = function (param_url) {
  'use strict';

  var result;

  result = Parcel_KnownParcelURL(Search.connect_info.parcel_prefixes, param_url);

  return result;
};

Search.KnownParcelBaggageURL = function (param_url) {
  'use strict';

  var result;

  result = Parcel_KnownBaggageURL(Search.connect_info.parcel_prefixes, param_url);

  return result;
};

Search.ScopeChanged = function () {
  'use strict';

  // Reset data queue
  //
  Search.control.data_queue = undefined;

  // Trigger search
  //
  Search.control.execute(Search.query);
};

Search.InBrowser_Object = function () {
  'use strict';

  var stop_words_array, stop_words_array_index, stop_word;

  // Search configuration
  //
  this.minimum_word_length = GLOBAL_MINIMUM_WORD_LENGTH;
  stop_words_array = GLOBAL_STOP_WORDS_ARRAY;
  this.stop_words = {};
  this.is_done = false;

  for (stop_words_array_index = 0;stop_words_array_index < stop_words_array.length;stop_words_array_index += 1) {
    stop_word = stop_words_array[stop_words_array_index];
    if (stop_word.length > 0) {
      this.stop_words[stop_word] = 1;
    }
  }

  // Initialize search data
  //
  this.data_queue = undefined;
  this.loadDataQueue = function () {
    'use strict';

    var this_reference, data_entry, script_element, ajax,
      search_scope_selections, search_scope_value,
      search_scope_data_indexes, scoped_data, search_scope_data_index, data_index, info;

    this_reference = this;

    Search.WriteSearchStateMessage();

    // Initialize data queue?
    //
    if (this.data_queue === undefined) {
      this.data_queue = Search.connect_info.parcel_sx.slice(0);
    }

    // Need to load search data?
    //
    if (this.data_queue.length > 0) {
      data_entry = this.data_queue.shift();

      // Load data
      //
      if (window.document.location.protocol === 'file:') {
        // Advance progress
        //
        Search.control.advance = function (param_info) {
          // Track data
          //
          Search.control.data.push(param_info);

          this_reference.is_done = Search.control.data.length === Search.connect_info.parcel_sx.length;

          if (this_reference.is_done) {
            document.getElementById('page_loading').style.display = 'none';
          }

          // Invoke method to load more data or perform search
          //
          Search.window.setTimeout(function () {
            Search.control.loadDataQueue();
          });
        };

        // Use script element
        //
        script_element = Search.window.document.createElement('script');
        script_element.src = data_entry + '?v=' + GLOBAL_GENERATION_HASH;
        Search.window.document.body.appendChild(script_element);
      } else {
        // Use AJAX
        //
        ajax = Browser.GetAJAX(window);

        ajax.onreadystatechange = function () {
          var info_as_text, info_prefix, info_suffix, info_data;

          if (ajax.readyState === 4) {
            // Prep info
            //
            info_as_text = ajax.responseText;
            info_prefix = 'var info =';
            info_suffix = ';Search.control.advance(info);';
            info_as_text = info_as_text.substring(
              info_as_text.indexOf(info_prefix) + info_prefix.length,
              info_as_text.lastIndexOf(info_suffix)
            );

            // Parse JSON
            //
            info_data = JSON.parse(info_as_text);

            // Track data
            //
            Search.control.data.push(info_data);

            this_reference.is_done = Search.control.data.length === Search.connect_info.parcel_sx.length;

            if (this_reference.is_done) {
              document.getElementById('page_loading').style.display = 'none';
            }

            // Invoke method to load more data or perform search
            //
            Search.window.setTimeout(function () {
              Search.control.loadDataQueue();
            });
          }
        };

        ajax.open('GET', data_entry, true);
        ajax.send(null);
      }
    } else {
      // Determine parcel data to process
      //
      search_scope_selections = Search.connect_info.search_scope_selections;

      scoped_data = this.data;

      if (search_scope_selections !== undefined &&
        ((this.data.length > 1) && (search_scope_selections.length > 0))) {

        // Check for 'all' scope - use all data without filtering
        if (search_scope_selections.length === 1 && search_scope_selections[0] === 'all') {
          // Keep scoped_data as this.data (no filtering)
        } else {
          scoped_data = [];
          search_scope_data_indexes = [];

          for (var i = 0;i < search_scope_selections.length;i++) {
            search_scope_value = search_scope_selections[i];

            // Defensive check: verify scope value exists in map before concatenating
            if (search_scope_value !== 'all' &&
              Search.connect_info.search_scope_map &&
              Search.connect_info.search_scope_map[search_scope_value]) {
              search_scope_data_indexes = search_scope_data_indexes.concat(Search.connect_info.search_scope_map[search_scope_value]);
            }
          }

          // Only filter if we have valid scope data indexes
          if (search_scope_data_indexes.length > 0) {
            for (search_scope_data_index = 0;search_scope_data_index < search_scope_data_indexes.length;search_scope_data_index += 1) {
              data_index = search_scope_data_indexes[search_scope_data_index];
              if (data_index !== undefined && this.data[data_index] !== undefined) {
                scoped_data.push(this.data[data_index]);
              }
            }
          } else {
            // Fallback: if no valid scope indexes, use all data
            scoped_data = this.data;
          }
        }
      }

      if (Search.control.is_done) {
        Search.query = Search.connect_info.query;
        Search.Execute(Search.query);
      }
    }
  };
  this.data = [];
  this.page_pairs_data = {};
  this.all_synonyms = {};

  this.setSearchCompleteCallback = function (param_object, param_method) {
    this.search_complete = { object: param_object, method: param_method };
  };

  this.setLinkTarget = function (param_target) {
    this.target = param_target;
  };

  this.execute = function (param_search_words) {
    var this_reference, data, data_entry, script_element, ajax, words_and_phrases,
      words, words_to_patterns, word_pattern_matches, word_index, word, is_word_last_word,
      word_as_regex_pattern, patterns_to_matches, search_scope_select, search_scope_value,
      search_scope_data_indexes, scoped_data, search_scope_data_index, data_index, info,
      word_as_regex, page_matches, page_match_index, page, page_with_score, word_page_matches,
      matched_words, first_page_match, pages, pages_to_check, page_id, pages_to_remove,
      synonymIndex, synonym, syn_word, synonym_as_regex_pattern, synonym_as_regex, current_word;

    // Data loaded?
    //
    Search.executing = true;

    this_reference = this;
    if (Search.connect_info === null) {
      Search.window.setTimeout(function () {
        this_reference.execute(param_search_words);
      }, 100);

      return;
    }

    // Prevent search for '*'
    //
    if (param_search_words === '*' || param_search_words === '') {
      Search.control.clearAllResults();

      return;
    }

    // Initialize data queue?
    //
    if (this.data_queue === undefined) {
      this.loadDataQueue();
    }

    this_reference.performAfterDelay(function () {

      // Get words
      //
      words_and_phrases = SearchClient.ParseSearchWords(param_search_words.toLowerCase(), this_reference.minimum_word_length, this_reference.stop_words);
      words = words_and_phrases['words'];
      words_to_patterns = {};
      word_pattern_matches = {};

      this_reference.performAfterDelay(function () {
        for (word_index = 0;word_index < words.length;word_index += 1) {

          current_word = words[word_index][0];

          // words[#][1] indicates context of word to match
          // can be one of: 'w' => word to match
          //                'l' => last word detected to match
          //                'p' => word to match that is part of phrase
          is_word_last_word = words[word_index][1] == 'l';

          // Translate word to regular expression
          //
          word_as_regex_pattern = SearchClient.WordToRegExpPattern(current_word);

          // Add wildcard to last word
          //
          if (is_word_last_word) {
            word_as_regex_pattern = word_as_regex_pattern.substring(0, word_as_regex_pattern.length - 1) + '.*$';
          }

          // Cache word to pattern result
          //
          words_to_patterns[current_word] = word_as_regex_pattern;

          word_pattern_matches[word_as_regex_pattern] = [];
        }

        this_reference.performAfterDelay(function () {
          // Determine parcel data to process
          //
          var search_scope_selections = Search.connect_info.search_scope_selections;

          scoped_data = this_reference.data;

          if (search_scope_selections !== undefined &&
            ((this_reference.data.length > 1) && (search_scope_selections.length > 0))) {

            // Check for 'all' scope - use all data without filtering
            if (search_scope_selections.length === 1 && search_scope_selections[0] === 'all') {
              // Keep scoped_data as this_reference.data (no filtering)
            } else {
              scoped_data = [];
              search_scope_data_indexes = [];

              for (var i = 0;i < search_scope_selections.length;i++) {

                search_scope_value = search_scope_selections[i];

                // Defensive check: verify scope value exists in map before concatenating
                if (search_scope_value !== 'all' &&
                  Search.connect_info.search_scope_map &&
                  Search.connect_info.search_scope_map[search_scope_value]) {
                  search_scope_data_indexes = search_scope_data_indexes.concat(Search.connect_info.search_scope_map[search_scope_value]);
                }
              }

              // Only filter if we have valid scope data indexes
              if (search_scope_data_indexes.length > 0) {
                for (search_scope_data_index = 0;search_scope_data_index < search_scope_data_indexes.length;search_scope_data_index += 1) {

                  data_index = search_scope_data_indexes[search_scope_data_index];
                  if (data_index !== undefined && this_reference.data[data_index] !== undefined) {
                    scoped_data.push(this_reference.data[data_index]);
                  }
                }
              } else {
                // Fallback: if no valid scope indexes, use all data
                scoped_data = this_reference.data;
              }
            }
          }

          // Process scoped data
          //

          this_reference.performAfterDelay(function () {
            patterns_to_matches = {};
            this_reference.all_synonyms = {};
            for (data_index = 0;data_index < scoped_data.length;data_index += 1) {

              info = scoped_data[data_index];
              this_reference.all_synonyms = info.synonyms;

              // Search info for word matches
              //
              for (word_as_regex_pattern in word_pattern_matches) {

                if (typeof word_pattern_matches[word_as_regex_pattern] === 'object') {
                  word_as_regex = new window.RegExp(word_as_regex_pattern);

                  // Check each word for a match
                  //
                  for (word in this_reference.all_synonyms) {

                    if (typeof this_reference.all_synonyms[word] === 'object') {
                      // Match?
                      //
                      if (word_as_regex.test(word)) {
                        for (synonymIndex = 0;synonymIndex < this_reference.all_synonyms[word].length;synonymIndex++) {

                          synonym = this_reference.all_synonyms[word][synonymIndex];
                          synonym_as_regex_pattern = word_as_regex_pattern.substring(word_as_regex_pattern.length - 3) == ".*$" ? "^" + synonym + ".*$" : "^" + synonym + "$";
                          synonym_as_regex = new window.RegExp(synonym_as_regex_pattern);

                          for (syn_word in info.words) {

                            this_reference.searchWord(syn_word, synonym_as_regex, info.words, page_matches, info.pages, word_pattern_matches, word_as_regex_pattern, patterns_to_matches);
                          }
                        }
                      }
                    }
                  }

                  for (word in info.words) {

                    this_reference.searchWord(word, word_as_regex, info.words, page_matches, info.pages, word_pattern_matches, word_as_regex_pattern, patterns_to_matches);
                  }
                }
              }
            }

            // Combine search results for each word pattern
            //
            this_reference.performAfterDelay(function () {
              var temp_page_id = ""; // enforce uniqueness, page_id = url_or_path + " " + group_guid
              var stop_words_keys = Object.keys(this_reference.stop_words);
              var doesRegexMatchAnyStopWords = function (param_patterns, param_stop_words_keys) {
                word_as_regex = new window.RegExp(param_patterns);

                return param_stop_words_keys.some(function (word) {
                  return word_as_regex.test(word);
                });
              };

              first_page_match = true;
              pages = {};
              for (word_as_regex_pattern in word_pattern_matches) {

                if (typeof word_pattern_matches[word_as_regex_pattern] === 'object') {
                  word_page_matches = word_pattern_matches[word_as_regex_pattern];

                  if (word_page_matches.length === 0) {
                    // Based on implicit AND for all phrases/words
                    // Each page result must match all words/phrases
                    // Only exceptions are for:
                    //   - words that match stop words
                    //   - words less than minimal_word_length
                    //   - last word is also a regular expression
                    //
                    if (doesRegexMatchAnyStopWords(word_as_regex_pattern, stop_words_keys)) {
                      continue;
                    } else {
                      // Pattern does not match any stop words => results are not valid for this page and stop looking
                      //
                      pages = {};
                      break;
                    }
                  }

                  if (first_page_match) {
                    // Add all pages
                    //
                    for (page_match_index = 0;page_match_index < word_page_matches.length;page_match_index += 1) {

                      page_with_score = word_page_matches[page_match_index];
                      temp_page_id = page_with_score.page[0] + ' ' + page_with_score.page[5];

                      if (pages[temp_page_id] !== undefined) {
                        if (pages[temp_page_id].score < page_with_score.score) {
                          pages[temp_page_id] = page_with_score;
                        }
                      }
                      else {
                        pages[temp_page_id] = page_with_score;
                      }
                    }
                  } else {
                    // Based on implicit AND.
                    // Combine scores of like pages.
                    // Remove accumulated pages not matching current word.
                    //   Except when the word is a stop word.
                    //
                    pages_to_check = {};
                    for (page_match_index = 0;page_match_index < word_page_matches.length;page_match_index += 1) {

                      page_with_score = word_page_matches[page_match_index];
                      temp_page_id = page_with_score.page[0] + ' ' + page_with_score.page[5]

                      pages_to_check[temp_page_id] = 1;

                      // Combine scoring info
                      //
                      if (pages[temp_page_id] !== undefined) {
                        pages[temp_page_id].score += page_with_score.score;
                      }
                    }

                    // If not a stop word then remove all pages missing it.
                    //
                    if (this_reference.stop_words[current_word] === undefined) {
                      pages_to_remove = {};
                      for (page_id in pages) {

                        if (typeof pages[page_id] === 'object') {
                          if (pages_to_check[page_id] === undefined) {
                            pages_to_remove[page_id] = true;
                          }
                        }
                      }
                      for (page_id in pages_to_remove) {

                        if (typeof pages_to_remove[page_id] === 'boolean') {
                          delete pages[page_id];
                        }
                      }
                    }
                  }

                  first_page_match = false;
                }
              }

              // Load phrase data
              //
              this_reference.performAfterDelay(function () {
                Search.control.phraseData(pages, words_and_phrases['phrases'], words_to_patterns, patterns_to_matches);
              });
            });
          });
        });
      });
    });
  };

  this.searchWord = function (param_word_to_search, param_word_as_regex, param_words_dictionary, page_matches, param_pages, param_word_pattern_matches, param_word_as_regex_pattern, param_patterns_to_matches) {
    var page_match_index, page, page_with_score, matched_words;

    if (typeof param_words_dictionary[param_word_to_search] === 'object') {
      page_matches = param_words_dictionary[param_word_to_search];

      // Match?
      //
      if (param_word_as_regex.test(param_word_to_search)) {
        // Add page info (page index and score alternate)
        //
        for (page_match_index = 0;page_match_index < page_matches.length;page_match_index += 2) {

          page = param_pages[page_matches[page_match_index]];
          page_with_score = { 'page': page, 'score': page_matches[page_match_index + 1] };
          param_word_pattern_matches[param_word_as_regex_pattern].push(page_with_score);
        }

        // Add param_word_to_search to match list for phrase processing
        //
        if (typeof param_patterns_to_matches[param_word_as_regex_pattern] !== 'object') {
          param_patterns_to_matches[param_word_as_regex_pattern] = {};
        }
        matched_words = param_patterns_to_matches[param_word_as_regex_pattern];
        matched_words[param_word_to_search] = true;
      }
    }
  };

  this.phraseData = function (param_pages, param_phrases, param_words_to_patterns, param_patterns_to_matches) {
    var done, page_id, page, page_pair_url, script_element, ajax;

    // Any phrases to check?
    //
    done = true;
    if (param_phrases.length > 0) {
      // Ensure all necessary page pairs loaded
      //
      for (page_id in param_pages) {

        if (typeof param_pages[page_id] === 'object') {
          // Page pairs loaded?
          //
          if (typeof Search.control.page_pairs_data[page_id] !== 'object') {
            // Get page data
            //
            page = param_pages[page_id];
            page_pair_url = Search.connect_info.base_url + page['page'][3];

            // Load data
            //
            if (window.document.location.protocol === 'file:') {
              // Advance progress
              //
              Search.control.loadWordPairs = function (param_pairs) {
                // Track data
                //
                Search.control.page_pairs_data[page_id] = param_pairs;

                // Invoke method to load more data or perform further processing
                //
                Search.control.phraseData(param_pages, param_phrases, param_words_to_patterns, param_patterns_to_matches);
              };

              // Use script element
              //
              script_element = Search.window.document.createElement('script');
              script_element.src = page_pair_url + '?v=' + GLOBAL_GENERATION_HASH;
              Search.window.document.body.appendChild(script_element);
            } else {
              // Use AJAX
              //
              ajax = Browser.GetAJAX(window);

              ajax.onreadystatechange = function () {
                var pairs_as_text, pairs_prefix, pairs_suffix, pairs;

                if (ajax.readyState === 4) {
                  // Prep data
                  //
                  pairs_as_text = ajax.responseText;
                  pairs_prefix = 'var pairs =';
                  pairs_suffix = ';Search.control.loadWordPairs(pairs);';
                  pairs_as_text = pairs_as_text.substring(
                    pairs_as_text.indexOf(pairs_prefix) + pairs_prefix.length,
                    pairs_as_text.lastIndexOf(pairs_suffix)
                  );

                  // Parse JSON
                  //
                  pairs = JSON.parse(pairs_as_text);

                  // Track data
                  //
                  Search.control.page_pairs_data[page_id] = pairs;

                  // Invoke method to load more data or perform further processing
                  //
                  Search.control.phraseData(param_pages, param_phrases, param_words_to_patterns, param_patterns_to_matches);
                }
              };

              ajax.open('GET', page_pair_url, true);
              ajax.send(null);
            }

            // Not done, need to load some data
            //
            done = false;
            break;
          }
        }
      }
    }

    // Done?
    //
    if (done) {
      Search.control.performAfterDelay(function () {
        Search.control.phraseCheck(param_pages, param_phrases, param_words_to_patterns, param_patterns_to_matches);
      });
    }
  };

  this.phraseCheckTriplets = function (param_phrase, param_index, param_page_triplets, param_words_to_patterns, param_patterns_to_matches) {
    var result, previous_word, current_word, next_word, triplet;

    // Check for end of phrase
    //
    if (param_phrase.length < 2) {
      return true;
    }

    result = false;

    // Get previous word
    //
    if (param_index > 0) {
      previous_word = param_phrase[param_index - 1];
    }
    else {
      previous_word = "";
    }

    // Get word pair
    //
    current_word = param_phrase[param_index];
    next_word = param_phrase[param_index + 1];

    if (typeof param_page_triplets[current_word] !== 'object') {
      return result;
    }

    triplet = param_page_triplets[current_word];

    if (triplet[next_word] === undefined) {
      return result;
    }

    if ((param_index == 0) ||
      (triplet[next_word].indexOf(previous_word) > -1)) {

      if ((param_index + 2) === param_phrase.length) {
        // At the end of the phrase
        //
        result = true;
      } else {
        // Check succeeding pairs
        //
        result = Search.control.phraseCheckTriplets(param_phrase, param_index + 1, param_page_triplets, param_words_to_patterns, param_patterns_to_matches);
      }
    }

    return result;
  };

  this.phraseCheck = function (param_pages, param_phrases, param_words_to_patterns, param_patterns_to_matches) {
    var pages_to_remove, page_id, page_pairs, phrase_index, matches, phrase;


    // Prepare to remove invalid pages
    //
    pages_to_remove = {};

    // Check phrases
    //
    if (param_phrases.length > 0) {
      // Review each page
      //
      for (page_id in param_pages) {

        if (typeof param_pages[page_id] === 'object') {
          // Access page pairs
          //
          page_pairs = Search.control.page_pairs_data[page_id];

          // Ensure all phrases occur in this page
          //
          matches = true;
          for (phrase_index = 0;phrase_index < param_phrases.length;phrase_index += 1) {

            phrase = param_phrases[phrase_index];

            // Check word pairs in the phrase
            //
            matches = Search.control.phraseCheckTriplets(phrase, 0, page_pairs, param_words_to_patterns, param_patterns_to_matches);

            // Early exit on first failed phrase
            //
            if (!matches) {
              break;
            }
          }

          // No match, so remove page from results
          //
          if (!matches) {
            pages_to_remove[page_id] = true;
          }
        }
      }
    }

    // Remove invalid pages
    //
    for (page_id in pages_to_remove) {

      if (typeof pages_to_remove[page_id] === 'boolean') {
        delete param_pages[page_id];
      }
    }

    // Display results
    //
    Search.control.performAfterDelay(function () {
      Search.control.displayResults(param_pages);
    });
  };

  this.displayResults = function (param_pages) {
    var pages_array, page_id, pages_array_index, buffer, page_with_score, page, container,
      search_results_count_container, this_reference;

    // Sort pages by rank
    //
    pages_array = [];
    this_reference = this;
    for (page_id in param_pages) {

      if (typeof param_pages[page_id] === 'object') {
        pages_array.push(param_pages[page_id]);
      }
    }
    if (pages_array.length > 0) {
      pages_array = pages_array.sort(SearchClient.ComparePageWithScore);
    }

    // Display results
    //
    Search.control.performAfterDelay(function () {
      buffer = [];
      for (pages_array_index = 0;pages_array_index < pages_array.length;pages_array_index += 1) {

        page_with_score = pages_array[pages_array_index];
        page = page_with_score.page;

        // Do not show files that have zero relevance from search results.
        //
        if (page_with_score.score > 0) {
          var pageUri, pageType, groupTitle;

          pageUri = SearchClient.EscapeHTML(page[0]);
          pageType = page[4];
          groupTitle = Search.group_titles[page[5]];
          var pageID = page[6]

          buffer.push('<div class="search_result">');

          if (pageUri) {
            var fileTypeIcons, resultTitleClasses;

            fileTypeIcons = '';
            resultTitleClasses = 'search_result_title';

            // Build HTML according to what type of search result this is
            //
            switch (pageType) {
              case 'internal-html':
                resultTitleClasses += ' search_result_internal_html';
                fileTypeIcons = '<i class="fa search_result_icon_html"></i>';
                break;
              case 'internal-pdf':
                resultTitleClasses += ' search_result_internal_pdf';
                fileTypeIcons = '<i class="fa search_result_icon_pdf"></i>';
                break;
              case 'external-html':
                resultTitleClasses += ' search_result_external_html';
                fileTypeIcons = '<i class="fa search_result_icon_external"></i>' +
                  '<i class="fa search_result_icon_html"></i>';
                break;
              case 'external-pdf':
                resultTitleClasses += ' search_result_external_html';
                fileTypeIcons = '<i class="fa search_result_icon_external"></i>' +
                  '<i class="fa search_result_icon_pdf"></i>';
                break;
              case 'content-page':
              default:
                resultTitleClasses += ' search_result_content_page';
                break;
            }

            buffer.push('<div class="' + resultTitleClasses + '">');

            buffer.push('<a target="connect_page" href="' + pageUri + '">' + SearchClient.EscapeHTML(page[1]) + '</a>');

            buffer.push(fileTypeIcons);

            buffer.push('</div>');
          }
          if (page[2].length > 0) {
            buffer.push('<div class="search_result_summary">' + SearchClient.EscapeHTML(page[2]) + '</div>');
          }

          var use_breadcrumbs_in_search_results = true;
          var html_elements = Search.window.document.getElementsByTagName('html');
          var result_breadcrumbs_div = document.getElementById('breadcrumbs:' + pageID);

          use_breadcrumbs_in_search_results = html_elements[0].getAttribute('data-search-result-include-breadcrumbs') === 'true';

          if (use_breadcrumbs_in_search_results && result_breadcrumbs_div !== null) {
            var search_result_breadcrumbs = result_breadcrumbs_div.outerHTML;

            buffer.push('<div class="search_result_breadcrumbs">' + search_result_breadcrumbs + '</div>');
          } else if (groupTitle) {
            buffer.push('<div class="search_result_group_name">' + groupTitle + '</div>');
          }

          buffer.push('</div>');
        }
      }

      container = window.document.getElementById('search_results_container');

      Search.WriteSearchStateMessage(pages_array.length);

      if (buffer.length === 0) {
        container.innerHTML = GLOBAL_NO_SEARCH_RESULTS_CONTAINER_HTML;
      } else {
        container.innerHTML = buffer.join('\n');
      }

      this_reference.search_complete.method.call(this_reference.search_complete.object, this_reference.search_complete.object, null);
    });
  };

  this.clearAllResults = function () {
    var container, data, search_results_count_container;

    container = window.document.getElementById('search_results_container');
    container.innerHTML = '';

    search_results_count_container = window.document.getElementById('search_results_count_container');
    if (search_results_count_container !== null) {
      search_results_count_container.style.display = 'none';
    }

    data = {
      'action': 'search_complete',
      'query': Search.query,
      'dimensions': Browser.GetWindowContentWidthHeight(Search.window)
    };
    Message.Post(Search.window.parent, data, Search.window);
  };

  this.performAfterDelay = function (param_function) {
    if (!Search.cancel && Search.query.length > 0) {
      setTimeout(param_function);
    } else {
      Search.executing = false;
      Search.cancel = false;
    }
  };
};

Search.Execute = function (param_query) {
  'use strict';

  var search_input;

  // Check for a search query string and execute it
  //
  if (Search.control.is_done) {
    // Update search words
    //
    if (Search.executing && (Search.query !== param_query)) {
      Search.cancel = true;
    }
    if (param_query !== undefined) {
      Search.query = param_query;
    }

    if (Search.query !== '') {
      if (Search.executing) {
        // Try again while search cancels
        //
        setTimeout(function () {
          Search.Execute(Search.query);
        });
      } else {
        // Search!
        //
        Search.control.execute(Search.query);
        Search.cancel = false;
        Search.executing = false;
      }
    } else {
      Search.control.clearAllResults();
    }
  }
  else {
    Search.control.loadDataQueue();
  }
};

Search.Listen = function (param_event) {
  'use strict';

  if (Search.dispatch === undefined) {
    Search.dispatch = {
      'set_focus': function (param_data) {
        var main_element;

        main_element = window.document.querySelector('main');
        if (main_element) {
          main_element.focus();
        }
      },
      'search_load': function (param_data) {
        Search.Load();
      },
      'search_load_breadcrumbs': function (param_data) {
        var breadcrumbs_data_div;

        breadcrumbs_data_div = document.getElementById('search_breadcrumbs_data');

        if (breadcrumbs_data_div !== null) {
          breadcrumbs_data_div.innerHTML += param_data.breadcrumbs;

          var breadcrumbs_links = breadcrumbs_data_div.querySelectorAll('a');

          for (var l = 0;l < breadcrumbs_links.length;l++) {
            var breadcrumbs_link = breadcrumbs_links[l];

            var breadcrumbs_span = document.createElement('span');
            breadcrumbs_span.className = 'WebWorks_Breadcrumb_Text';
            breadcrumbs_span.innerHTML = breadcrumbs_link.innerHTML;

            breadcrumbs_link.replaceWith(breadcrumbs_span);
          }
        }
      },
      'search_get_page_size': function (param_data) {
        var data;

        data = {
          'action': 'search_page_size',
          'dimensions': Browser.GetWindowContentWidthHeight(Search.window),
          'stage': param_data.stage
        };
        Message.Post(Search.window.parent, data, Search.window);
      },
      'search_connect_info': function (param_data) {
        var data;

        if (!Search.ready) {
          Search.Load();
        } else {
          Search.connect_info = param_data;

          delete Search.connect_info['action'];

          // Load filter message
          //
          if (Search.connect_info.search_scope_selection_titles !== undefined) {
            if (Search.connect_info.search_scope_map !== undefined) {
              document.getElementById('search_filter_message_container').style.display = 'block';
              document.getElementById('search_filter_by_groups').innerHTML = Search.connect_info.search_scope_selection_titles
            }
            else {
              document.getElementById('search_filter_message_container').style.display = 'none';
            }
          }

          // Load Group titles to object for Search Results
          //
          if (Search.connect_info.search_scopes !== undefined) {
            Search.CreateGroupTitlesObject(Search.connect_info.search_scopes);
          }

          Search.Execute(param_data.query);
        }
      }
    };
  }

  try {
    // Dispatch
    //
    Search.dispatch[param_event.data.action](param_event.data);
  } catch (ignore) {
    // Keep on rolling
    //
  }
};

Search.SearchQueryHighlight = function (param_search_query) {
  'use strict';

  var search_results_container, expressions;

  // Locate search results container
  //
  search_results_container = window.document.getElementById('search_results_container');

  // Remove highlights
  //
  Highlight.RemoveFromHierarchy(Search.window.document, search_results_container, 'search_result_highlight');

  // Highlight words
  //
  if (param_search_query !== undefined && param_search_query !== '') {
    // Convert search query into expressions
    //
    expressions = SearchClient.SearchQueryToExpressions(param_search_query, Search.control.all_synonyms, Search.control.minimum_word_length, Search.control.stop_words);

    // Apply highlights
    //
    Highlight.ApplyToHierarchy(Search.window.document, search_results_container, 'search_result_highlight', expressions);
  }
};

Search.SearchResultCount = function (param_result_count) {
  'use strict';

  // Hide search loading container and show search result count container
  //
  var search_results_count_container, search_results_loading_container, count_span, count_formatted, has_all_elements;

  search_results_count_container = window.document.getElementById('search_results_count_container');
  search_results_loading_container = window.document.getElementById('search_results_loading_container');
  count_span = window.document.getElementById('search_results_count');
  has_all_elements = search_results_count_container && search_results_loading_container && count_span;

  if (has_all_elements && !isNaN(param_result_count)) {
    search_results_loading_container.style.display = 'none';
    search_results_count_container.style.display = 'block';

    count_formatted = param_result_count.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    count_span.innerHTML = count_formatted;
  }
};

Search.SearchResultLoading = function () {
  'use strict';

  // Hide search result count container and show search loading container
  //
  var search_results_count_container, search_results_loading_container, has_all_elements;

  search_results_count_container = window.document.getElementById('search_results_count_container');
  search_results_loading_container = window.document.getElementById('search_results_loading_container');
  has_all_elements = search_results_count_container && search_results_loading_container;

  if (has_all_elements) {
    search_results_count_container.style.display = 'none';
    search_results_loading_container.style.display = 'block';
  }
};

Search.WriteSearchStateMessage = function (param_result_count) {
  'use strict';

  if (Search.control.is_done) {
    Search.SearchResultCount(param_result_count);
  } else if (Search.query) {
    Search.SearchResultLoading();
  }
};

Search.CreateGroupTitlesObject = function (param_search_scopes) {
  'use strict';

  var search_scopes, search_scope, scope_context, scope_title;

  search_scopes = param_search_scopes;

  if (typeof search_scopes !== 'undefined') {
    for (var i = 0;i < search_scopes.length;i++) {
      search_scope = search_scopes[i];

      if (typeof search_scope['title'] !== 'undefined' &&
        typeof search_scope['id'] !== 'undefined') {
        scope_context = search_scope['id'];
        scope_title = search_scope['title'];
        Search.group_titles[scope_context] = scope_title;
      }

      if (typeof search_scope['children'] !== 'undefined') {
        Search.CreateGroupTitlesObject(search_scope['children']);
      }
    }
  }
};

Search.SendWindowClicked = function () {
  'use strict';

  var data;

  data = {
    'action': 'search_page_clicked'
  };
  Message.Post(Search.window.parent, data, Search.window);
};

Search.SendSearchHelpfulButtonClick = function (param_value) {
  var data, helpful_rating_object, search_query;

  helpful_rating_object = Browser.GetLocalStorageItem('search_helpful_rating');

  if (helpful_rating_object !== null) {

    search_query = Search.query.replace(/\s+/g, " ").trim();

    if (!helpful_rating_object.hasOwnProperty(search_query) || helpful_rating_object[search_query] !== param_value) {

      helpful_rating_object[search_query] = param_value;

      try {
        Browser.UpdateLocalStorageItem('search_helpful_rating', helpful_rating_object);
      } catch (e) {
        helpful_rating_object = {};
        helpful_rating_object[search_query] = param_value;
        Browser.DeleteLocalStorageItem('search_helpful_rating');
        Browser.CreateLocalStorageItem('search_helpful_rating', helpful_rating_object);
      }

      Search.SetSelectedStateForHelpfulButton(param_value);

      data = {
        'action': 'search_helpful_button_click',
        'helpful': param_value,
        'href': Search.window.document.location.href
      };

      Message.Post(Search.window.parent, data, Search.window);
    } else {
      //do nothing
    }
  }
};

Search.Load = function () {
  'use strict';

  var onSearchLinkClick, onSearchLinkClickInBaggage, onSearchLinkClickInExternalBaggage, onSearchComplete, search_page_load_data, helpful_button, unhelpful_button, helpful_rating;

  // Define callbacks
  //
  onSearchLinkClick = function (param_event) {
    var data;

    data = {
      'action': 'search_display_link',
      'href': this.href,
      'title': this.innerText,
      'minimum_word_length': Search.control.minimum_word_length,
      'stop_words': Search.control.stop_words
    };
    Message.Post(Search.window.parent, data, Search.window);

    return false;
  };

  onSearchLinkClickInBaggage = function (param_event) {
    var data;

    data = {
      'wwr_a': 'search_display_link',
      'wwr_q': Search.query,
      'wwr_s': Search.control.all_synonyms,
      'wwr_mwl': Search.control.minimum_word_length,
      'wwr_sw': Search.control.stop_words
    };

    window.localStorage['wwreverbsearch'] = JSON.stringify(data);
    window.open(this.href);

    return false;
  };

  onSearchLinkClickInExternalBaggage = function (param_event) {
    var params;

    params = "wwr_a=search_display_link" +
      "&wwr_q=" + Browser.EncodeURIComponentIfNotEncoded(Search.query) +
      "&wwr_s=" + Browser.EncodeURIComponentIfNotEncoded(Search.control.synonyms) +
      "&wwr_mwl=" + Browser.EncodeURIComponentIfNotEncoded(Search.control.minimum_word_length) +
      "&wwr_sw=" + Browser.EncodeURIComponentIfNotEncoded("");
    // NOTE: sending empty dictionary of stop words -- too long

    if (this.href.indexOf('?') === -1) {
      params = '?' + params;
    }
    else {
      params = '&' + params;
    }

    window.open(this.href + params);

    return false;
  };

  onSearchComplete = function (param_search_control, param_searcher) {
    var index, link, search_uri, encoded_search_uri, data;

    // Intercept search result links
    //
    for (index = 0;index < window.document.links.length;index += 1) {
      link = window.document.links[index];

      if (link.target === 'connect_page') {
        // Same hierarchy?
        //
        if (Browser.SameHierarchy(Search.connect_info.base_url, link.href)) {
          // Verify parcel is known
          //
          if ((Search.KnownParcelURL(link.href)) && (!Search.KnownParcelBaggageURL(link.href))) {
            // Handle via Connect run-time
            //
            link.onclick = onSearchLinkClick;
          } else {
            // Open in a new window
            //
            link.target = '_blank';
            // Assigning the new function to the onclick event
            //
            link.onclick = onSearchLinkClickInBaggage;
          }
        } else {
          // Open in a new window
          //
          link.target = '_blank';
          // Assigning the new function to the onclick event even when it's not of the SameHierarchy but it could be an External URL
          //
          link.onclick = onSearchLinkClickInExternalBaggage;
        }
      }
    }

    Browser.CreateLocalStorageItem('search_helpful_rating', {});

    helpful_button = document.getElementById('helpful_thumbs_up');
    unhelpful_button = document.getElementById('helpful_thumbs_down');

    if (helpful_button !== null && unhelpful_button !== null) {
      helpful_button.onclick = function () { Search.SendSearchHelpfulButtonClick('yes'); };
      unhelpful_button.onclick = function () { Search.SendSearchHelpfulButtonClick('no'); };

      // Keyboard support for helpful buttons (role="button" requires Enter and Space)
      helpful_button.onkeydown = function (param_event) {
        if (param_event.key === 'Enter' || param_event.key === ' ') {
          param_event.preventDefault();
          Search.SendSearchHelpfulButtonClick('yes');
        }
      };
      unhelpful_button.onkeydown = function (param_event) {
        if (param_event.key === 'Enter' || param_event.key === ' ') {
          param_event.preventDefault();
          Search.SendSearchHelpfulButtonClick('no');
        }
      };

      helpful_rating = Search.GetHelpfulRating();

      if (helpful_rating !== undefined) {
        Search.SetSelectedStateForHelpfulButton(helpful_rating);
      } else {
        Search.ResetSelectedStateForHelpfulButtons();
      }
    }

    // Highlight search words and phrases
    //
    Search.SearchQueryHighlight(Search.query);

    // Notify parent
    //
    data = {
      'action': 'search_complete',
      'query': Search.query,
      'synonyms': Search.control.all_synonyms,
      'dimensions': Browser.GetWindowContentWidthHeight(Search.window)
    };
    Message.Post(Search.window.parent, data, Search.window);
    Search.executing = false;
    Search.cancel = false;
  };

  // Search control settings
  //
  Search.control = new Search.InBrowser_Object();
  Search.control.setSearchCompleteCallback(this, onSearchComplete);
  Search.control.setLinkTarget('connect_page');

  Browser.TrackDocumentChanges(Search.window, Search.window.document, Search.ContentChanged);
  Search.window.onresize = Search.ContentChanged;

  Search.ready = true;

  // Initialize keyboard shortcuts for navigation (forwarded to parent)
  //
  Search.InitNavigationKeyboardShortcuts();

  // Initialize F6 region cycling (forwarded to parent)
  //
  Search.InitRegionCycling();

  // Ready to search
  //
  search_page_load_data = {
    'action': 'search_page_load_data',
    'dimensions': Browser.GetWindowContentWidthHeight(Search.window)
  };
  Message.Post(Search.window.parent, search_page_load_data, Search.window);
};

/**
 * Initialize keyboard shortcuts for page navigation.
 * Forwards Alt+N, Alt+P, Alt+Home to parent frame.
 */
Search.InitNavigationKeyboardShortcuts = function () {
  'use strict';

  // Delegate to shared utility in common.js
  Browser.InitNavigationKeyboardShortcuts(Search.window);
};

/**
 * Initialize F6 region cycling keyboard support.
 * Forwards F6/Shift+F6 to parent frame for region cycling.
 */
Search.InitRegionCycling = function () {
  'use strict';

  // Delegate to shared utility in common.js
  Browser.InitRegionCycling(Search.window);
};

Search.GetHelpfulRating = function () {
  var helpful_rating, helpful_rating_object, search_query;
  helpful_rating = null;

  search_query = Search.query.replace(/\s+/g, " ").trim();

  helpful_rating_object = Browser.GetLocalStorageItem('search_helpful_rating');
  if (helpful_rating_object !== null) {
    if (helpful_rating_object.hasOwnProperty(search_query)) {
      helpful_rating = helpful_rating_object[search_query];
    }
  }

  return helpful_rating;
};

Search.SetSelectedStateForHelpfulButton = function (param_helpful_rating) {
  'use strict';

  // Delegate to shared utility in common.js
  Browser.SetHelpfulButtonState(param_helpful_rating);
};

Search.ResetSelectedStateForHelpfulButtons = function () {
  // Delegate to shared utility with undefined to reset both buttons
  Browser.SetHelpfulButtonState(undefined);
};

Search.ContentChanged = function () {
  "use strict";

  var data;

  data = {
    action: "search_page_size",
    dimensions: Browser.GetWindowContentWidthHeight(Search.window)
  };

  Message.Post(Search.window.parent, data, Search.window);

  return true;
};

Search.HandleRedirect = function () {
  'use strict';

  if (Search.window === Search.window.top && Search.window.navigator.userAgent.indexOf('bot/') === -1) {
    // Redirect
    //
    var event_or_redirect_url;

    if (document.getElementById('search_onload_url')) {
      event_or_redirect_url = document.getElementById('search_onload_url').value;
    }

    if (event_or_redirect_url && typeof event_or_redirect_url === 'string') {
      var redirect_url = event_or_redirect_url;

      // First check query string parameters (?q= and &scope=)
      //
      var query_params = new URLSearchParams(Search.window.document.location.search);
      var q_value = query_params.get('q');
      var scope_value = query_params.get('scope');

      if (q_value) {
        // Sanitize and append query as hash
        //
        q_value = q_value.replace(/[\\<>:;"']|%5C|%3C|%3E|%3A|%3B|%22|%27/gi, '');
        redirect_url += encodeURIComponent(q_value);

        if (scope_value) {
          // Scope values are separated by / - sanitize each part
          //
          var scope_parts = scope_value.split('/');
          var sanitized_parts = [];
          for (var i = 0;i < scope_parts.length;i++) {
            var part = scope_parts[i].replace(/[\\<>:;"']|%5C|%3C|%3E|%3A|%3B|%22|%27/gi, '');
            if (part) {
              sanitized_parts.push(encodeURIComponent(part));
            }
          }
          if (sanitized_parts.length > 0) {
            redirect_url += '#scope/' + sanitized_parts.join('/');
          }
        }
      } else if (Search.window.document.location.hash.length > 1) {
        // Fallback to existing hash handling
        //
        var search_hash = Search.window.document.location.hash.substring(1);

        search_hash = search_hash.replace(/[\\<>:;"']|%5C|%3C|%3E|%3A|%3B|%22|%27/gi, '');
        redirect_url += '#' + search_hash;
      }

      Search.window.document.location.replace(redirect_url);
    }
  }
};

// Handle load
//
//Search.OnLoad = function () {
//  'use strict';
//
//   if (!Search.loading) {
//    Search.loading = true;
//    Search.Load();
//  }
//};

// Start running as soon as possible
//
if (window.addEventListener !== undefined) {
  window.addEventListener('load', Search.HandleRedirect, false);
} else if (window.attachEvent !== undefined) {
  window.attachEvent('onload', Search.HandleRedirect);
}

window.onclick = function (event) {
  Search.SendWindowClicked();
};

// Setup for listening
//
Message.Listen(window, function (param_event) {
  Search.Listen(param_event);
});
