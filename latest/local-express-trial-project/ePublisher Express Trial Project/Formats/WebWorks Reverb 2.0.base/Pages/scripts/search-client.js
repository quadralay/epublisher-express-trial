// Copyright (c) 2011-2025 Quadralay Corporation.  All rights reserved.
//
// ePublisher 2025.1
//

function GetTermsFromArray(param_set) {
    var result = new Array();
    var entry;

    param_set.forEach(function (element) {
        entry = new Array(element[0], 'w'); // [<word>, <type>]
        result.push(entry);
    });

    return result;
};

// SearchClient
//
var SearchClient = {};

SearchClient.SearchReplace = function (param_string, param_search_string, param_replace_string) {
    'use strict';

    var  result, index;

    result = param_string;

    if ((param_search_string.length > 0) && (result.length > 0)) {
        index = result.indexOf(param_search_string, 0);
        while (index !== -1) {
            result = result.substring(0, index) + param_replace_string + result.substring(index + param_search_string.length, result.length);
            index += param_replace_string.length;

            index = result.indexOf(param_search_string, index);
        }
    }

    return result;
};

SearchClient.EscapeRegExg = function (param_string) {
    'use strict';

    var result;

    // Initialize result
    //
    result = param_string;

    // Escape special characters
    // \ . ? + - ^ $ | ( ) [ ] { }
    //
    result = SearchClient.SearchReplace(result, '\\', '\\\\');
    result = SearchClient.SearchReplace(result, '.', '\\.');
    result = SearchClient.SearchReplace(result, '?', '\\?');
    result = SearchClient.SearchReplace(result, '+', '\\+');
    result = SearchClient.SearchReplace(result, '^', '\\^');
    result = SearchClient.SearchReplace(result, '$', '\\$');
    result = SearchClient.SearchReplace(result, '|', '\\|');
    result = SearchClient.SearchReplace(result, '(', '\\(');
    result = SearchClient.SearchReplace(result, ')', '\\)');
    result = SearchClient.SearchReplace(result, '[', '\\[');
    result = SearchClient.SearchReplace(result, ']', '\\]');
    result = SearchClient.SearchReplace(result, '{', '\\{');
    result = SearchClient.SearchReplace(result, '}', '\\}');
    result = SearchClient.SearchReplace(result, '*', '.*'); // support simple wildcards

    // Windows IE 4.0 is brain dead
    //
    result = SearchClient.SearchReplace(result, '/', '[/]');

    return result;
};

SearchClient.WordToRegExpPattern = function (param_word) {
    'use strict';

    var result;

    // Escape special characters
    //
    result = SearchClient.EscapeRegExg(param_word);

    // Add ^ and $ to force whole string match
    //
    result = '^' + result + '$';

    return result;
};

SearchClient.EscapeHTML = function (param_html) {
    'use strict';

    var  escapedHTML = param_html;

    // Escape problematic characters
    // & < > "
    //
    escapedHTML = SearchClient.SearchReplace(escapedHTML, '&', '&amp;');
    escapedHTML = SearchClient.SearchReplace(escapedHTML, '<', '&lt;');
    escapedHTML = SearchClient.SearchReplace(escapedHTML, '>', '&gt;');
    escapedHTML = SearchClient.SearchReplace(escapedHTML, '"', '&quot;');

    return escapedHTML;
};

SearchClient.SplitWordsWithUnicode = function (param_string) {
    'use strict';

    const words = [];
    let currentWord = '';

    for (let i = 0; i < param_string.length; i++) {
        const char = param_string[i];

        if (Unicode.CheckBreakAtIndex(param_string, i)) {
            if (currentWord.length > 0) {
                words.push(currentWord);
                currentWord = '';
            }
        }

        // Skip whitespace characters entirely
        if (!/\s/.test(char)) {
            currentWord += char;
        }
    }

    // Add final word if any
    if (currentWord.length > 0) {
        words.push(currentWord);
    }

    return words;
};

SearchClient.ParseWordsAndPhrases = function (param_input) {
    'use strict';

    // Determine if words are in a phrase by detecting start and end quotes.
    // Add complete phrase or isolated word to results list of phrases and words.
    // 'p' indicates a phrase (group of words).
    // 'w' indicates a word
    // 'l' indicates a word that is last in the search query, also indicates may be a partial word (not fully delimited as a word).
    //
    var results = [];
    var current = '';
    var isLetterRegex = /\p{L}/u;
    var inQuote = false;
    var i, char;

    function isQuoteChar(c) {
        return c === '"';
    }

    for (i = 0; i < param_input.length; i++) {
        char = param_input[i];

        if (isQuoteChar(char)) {
            if (inQuote) {
                // Ending a phrase
                inQuote = false;
                if (current.length > 0) {
                    results.push([current.trim(), 'p']);
                    current = '';
                }
            } else {
                // Starting a phrase
                inQuote = true;
                current = '';
            }
        } else if (inQuote) {
            current += char;
        } else {
            // Not in a quote, check for word boundary
            if (Unicode.CheckBreakAtIndex(param_input, i)) {
                if (current.length > 0) {
                    // Record the previous word
                    //
                    results.push([current.trim(), 'w']);
                    current = '';
                } else if (isLetterRegex.test(char)) {
                    // Starting a new word with this letter
                    //
                    current = char;
                }
            } else {
                current += char;
            }
        }
    }

    // Final word or phrase
    if (current.length > 0) {
        var lastType = inQuote ? 'p' : 'l';
        results.push([current.trim(), lastType]);
    }

    return results;
};

SearchClient.SearchQueryToExpressions = function (param_search_query, param_all_synonyms, param_minimum_word_length, param_stop_words) {
    'use strict';

    var result,  words_and_phrases, index, expression, words, word, phrases, phrase, is_in_phrase, is_word_last_word;

    result = [];
    if (param_search_query !== undefined) {
        words_and_phrases = SearchClient.ParseSearchWords(param_search_query.toLowerCase(), param_minimum_word_length, param_stop_words);

        // Start with raw phrases
        //
        phrases = words_and_phrases['raw_phrases'];
        for (index = 0; index < phrases.length; index += 1) {
          phrase = phrases[index];

          if ((phrase !== "*") &&
              (phrase.length > 0)) {
            expression = SearchClient.EscapeRegExg(phrase);
            expression = SearchClient.SearchReplace(expression, ".*", "\\S*");
            result.push(expression);
          }
        }

        // Add words not in phrases
        //
        words = words_and_phrases['words'];
        words = SearchClient.AddSynonyms(words, param_all_synonyms);
        for (index = 0; index < words.length; index += 1) {
            word = words[index][0];
            is_in_phrase = (words[index][1] === 'p');
            is_word_last_word = (words[index][1] === 'l'); // is last word in query?

            // Avoid highlighting everything and if last word add wildcard suffix
            //
          if ((word !== '*') &&
              (!is_in_phrase) &&
              (word.length > 0)) {
                expression = SearchClient.EscapeRegExg(word);
                if (is_word_last_word) {
                    expression = expression + '.*'; // add wildcard suffix
                }
                expression = SearchClient.SearchReplace(expression, '.*', '\\S*');
                result.push(expression);
            }
        }
    }

    return result;
};

SearchClient.AddSynonyms = function (param_words_and_phrases, param_all_synonyms) {
    'use strict';

    var result_words, result_phrases, index, word_or_phrase, word_as_regex_pattern, word_as_regex, synonym;

    result_words = new Array();
    result_phrases = new Array();

    for (index = 0; index < param_words_and_phrases.length; index += 1) {
        word_or_phrase = param_words_and_phrases[index][0];
        if(param_words_and_phrases[index][1] == 'p'){
            // Phrase
            SearchClient.phraseGeneration(
                word_or_phrase.split(" "),
                0,
                param_all_synonyms
            ).map(
                function(phrase) {
                    return result_phrases.push([phrase, 'p']);
                }
            );
        } else if (param_words_and_phrases[index][1] == 'l'){
          // Last Word (with wildcard suffix: .*), ignore
          //
        } else {
            // Word
            word_as_regex_pattern = SearchClient.WordToRegExpPattern(word_or_phrase);
            word_as_regex_pattern = word_as_regex_pattern.substring(0, word_as_regex_pattern.length - 1) + '.*$';
            word_as_regex = new window.RegExp(word_as_regex_pattern);
            for(synonym in param_all_synonyms)
                if(word_as_regex.test(synonym))
                    param_all_synonyms[synonym].map(function(word) {return result_words.push([word, 'w']);});
        }
    }

    return param_words_and_phrases.concat(GetTermsFromArray(result_words)).concat(GetTermsFromArray(result_phrases));
};

SearchClient.phraseGeneration = function (param_phrase, param_phrase_index, param_synonyms){
    'use strict';

    if(param_phrase_index >= param_phrase.length)
        return [];

    var result, synonym, original_word, index, synonyms_array;

    result = [];

    synonyms_array = param_synonyms[param_phrase[param_phrase_index]];
    if(synonyms_array !== undefined && synonyms_array.length > 0){
        result = result.concat(SearchClient.phraseGeneration(param_phrase, param_phrase_index + 1, param_synonyms));
        for(index = 0; index < synonyms_array.length; index++){
            synonym = synonyms_array[index];
            original_word = param_phrase[param_phrase_index];
            param_phrase[param_phrase_index] = synonym;
            result.push(param_phrase.join(" "));
            result = result.concat(SearchClient.phraseGeneration(param_phrase, param_phrase_index + 1, param_synonyms));
            param_phrase[param_phrase_index] = original_word;
        }
    }
     else
         result = result.concat(SearchClient.phraseGeneration(param_phrase, param_phrase_index + 1, param_synonyms));

    return result;
};

SearchClient.ParseSearchWords = function (param_search_words_string, param_minimum_word_length, param_stop_words) {
    'use strict';

  var result_words, result_phrases, result_raw_phrases, wordsAndPhrases, wordsAndPhrasesIndex, wordOrPhrase, words, wordsIndex, word, result, word_entry, search_words_string, is_word_last_word, is_phrase;

    result_words = [];
    result_phrases = [];
    result_raw_phrases = [];

    // Remove last unbalanced quote (incomplete phrase)
    //
    const unbalanced_quote_regex = /^(?:[^"]*"[^"]*")*[^"]*"[^"]*$/;
    var RemoveUnbalancedQuote = function (param_query) {
        if (unbalanced_quote_regex.test(param_query)) {
            var last_quote_index = param_query.lastIndexOf('"');

            result = param_query.slice(0, last_quote_index) + param_query.slice(last_quote_index + 1);
        }
        else {
            result = param_query;
        }

        return result;
    }
    search_words_string = RemoveUnbalancedQuote(param_search_words_string);

    // Add search words to hash
    //
    wordsAndPhrases = SearchClient.ParseWordsAndPhrases(search_words_string);
    for (wordsAndPhrasesIndex = 0; wordsAndPhrasesIndex < wordsAndPhrases.length; wordsAndPhrasesIndex += 1) {
        is_word_last_word = wordsAndPhrases[wordsAndPhrasesIndex][1] === 'l';
        is_phrase = wordsAndPhrases[wordsAndPhrasesIndex][1] === 'p';
        wordOrPhrase = wordsAndPhrases[wordsAndPhrasesIndex][0];
        words = SearchClient.SplitWordsWithUnicode(wordOrPhrase);

        // Phrase?
        //
        if (is_phrase) {
            result_phrases[result_phrases.length] = [];
            result_raw_phrases[result_raw_phrases.length] = wordOrPhrase;
        }

        // Process words
        //
        for (wordsIndex = 0; wordsIndex < words.length; wordsIndex += 1) {
            word = words[wordsIndex];

            // Add to phrase words list (if necessary)
            //
            if (is_phrase) {
                result_phrases[result_phrases.length - 1].push(word);
            }

            // Skip words below the minimum word length
            //
            if ((word.length > 0) && (word.length >= param_minimum_word_length)) {
                // Skip stop words when not processing the last word (which has implicit wildcard)
                //
                if (param_stop_words[word] === undefined || is_word_last_word) {
                    // Add to search words list
                    //
                    word_entry = [word, wordsAndPhrases[wordsAndPhrasesIndex][1]];
                    result_words.push(word_entry);
                }
            }
        }
    }

    result = { 'words': result_words, 'phrases': result_phrases, 'raw_phrases': result_raw_phrases };

    return result;
};

SearchClient.ComparePageWithScore = function (param_alpha, param_beta) {
    'use strict';

    var result = 0;

    if (param_alpha.score < param_beta.score) {
        result = 1;
    } else if (param_alpha.score > param_beta.score) {
        result = -1;
    }

    return result;
};
