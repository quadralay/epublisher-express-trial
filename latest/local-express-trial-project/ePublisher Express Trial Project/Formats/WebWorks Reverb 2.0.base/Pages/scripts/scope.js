// Copyright (c) 2020-2025 Quadralay Corporation.  All rights reserved.
//
// ePublisher 2025.1
//

// Scope
//
var Scope = {
  search_scopes: []
};

Scope.AddSearchScope = function (param_parcel_anchor,
                                 param_id,
                                 param_context,
                                 param_data_index) {
  'use strict';

  var entry, parent_scopes, parent_li, grandparent_li,
      parent_scope_div, parent_scope_a, parent_scope_title,
      current_level, parent_scope_index, index, parent_entry, level_entry;

  // Create entry
  //
  entry = {
    title: param_parcel_anchor.innerText,
    id: param_id,
    context: param_context,
    data_index: param_data_index
  };

  // Determine parent scopes
  //
  parent_scopes = [];
  parent_li = Browser.FindParentWithTagName(param_parcel_anchor, 'li');
  grandparent_li = null;
  if (parent_li !== null) {
    grandparent_li = Browser.FindParentWithTagName(parent_li, 'li');
  }
  while (grandparent_li !== null) {
    // Prepend to list of parent scopes
    //
    parent_scope_div = Browser.FirstChildElementWithTagName(grandparent_li, 'div');
    parent_scope_a = Browser.FirstChildElementWithTagName(parent_scope_div, 'a');
    if (parent_scope_a !== null) {
      parent_scope_title = parent_scope_a.innerText;
    } else {
      parent_scope_title = parent_scope_div.innerText;
    }
    parent_scopes.push(parent_scope_title);

    // Advance
    //
    grandparent_li = Browser.FindParentWithTagName(grandparent_li, 'li');
  }

  // Create entries for all parent scopes
  //
  current_level = Scope.search_scopes;
  for (parent_scope_index = parent_scopes.length - 1; parent_scope_index >= 0; parent_scope_index -= 1) {
    parent_scope_title = parent_scopes[parent_scope_index];

    // Search for existing parent scope
    //
    parent_entry = null;
    for (index = 0; index < current_level.length; index += 1) {
      level_entry = current_level[index];
      if (level_entry['title'] === parent_scope_title) {
        // Found it!
        //
        parent_entry = level_entry;
        break;
      }
    }

    // Create parent entry if not found
    //
    if (parent_entry === null) {
      parent_entry = {
        title: parent_scope_title,
        children: []
      };

      if (current_level.indexOf(parent_entry) === -1) {
        current_level.push(parent_entry);
      }
    }

    // Update current level
    //
    if (parent_entry.children !== undefined) {
      current_level = parent_entry.children;
    }
  }

  // Append entry
  //
  if (current_level.indexOf(entry) === -1) {
    current_level.push(entry);
  }
};

Scope.ClearSearchScopes = function () {
  'use strict';

  Scope.search_scopes = [];
};

Scope.SearchScopeCheckbox = function (param_id) {
  'use strict';

  var checkbox, ids_as_array;

  if (param_id) {
    checkbox = document.getElementById(param_id);
    ids_as_array = param_id.split('_');

    if (ids_as_array.length === 1) {
      // Select all children or not
      //
      Scope.SearchScopeParentSelection(param_id, checkbox.checked);
    }
    else {
      Scope.SearchScopeChildSelection(param_id, checkbox.checked);
    }

    Scope.UpdateSearchScopeSelections();

    if (Connect.SearchEnabled()) {
      // Execute search directly with current scope state
      // Scope.search_scope_selections is already updated by UpdateSearchScopeSelections()
      // No need to call NavigateToSearch which would redundantly re-process scope
      Scope.ExecuteScopedSearch();
    }
  }
};

/**
 * Execute search with current scope selections and update URL.
 * This is used for user-initiated scope changes where the scope state
 * (Scope.search_scope_selections) is already correct.
 * Does NOT re-parse scope from URL or sync checkbox UI (already in correct state).
 */
Scope.ExecuteScopedSearch = function () {
  'use strict';

  var query, scope_titles, history_url, search_state, search_title;

  query = Connect.search_query || '';

  // Build scope titles for URL
  scope_titles = [];
  if (Scope.search_scope_selections.length > 0 && Scope.search_scope_selections[0] !== 'all') {
    for (var i = 0; i < Scope.search_scope_selections.length; i++) {
      var scope_selection = Scope.search_scope_selections[i];
      if (Scope.search_scopes[scope_selection]) {
        scope_titles.push(Scope.search_scopes[scope_selection].title);
      }
    }
  }

  // Build search state for history
  search_state = {
    type: 'search',
    query: query,
    scope: Scope.search_scope_selections,
    previousPage: Navigation.page_info ? {
      href: Navigation.page_info.href,
      hash: Navigation.page_info.hash,
      title: Navigation.page_info.title,
      id: Navigation.page_info.id
    } : null
  };

  // Build URL for history
  if (Connect_Window.location.protocol === 'file:') {
    // Hash-based URL for file:// protocol
    var hash_parts = ['#search'];
    if (query) {
      hash_parts[0] += '/' + encodeURIComponent(query);
    }
    if (scope_titles.length > 0) {
      hash_parts.push('#scope/' + encodeURIComponent(scope_titles.join('/')));
    }
    history_url = hash_parts.join('');
  } else {
    // Query params URL for http(s):// protocol
    history_url = Navigation.search_page_url;
    if (query) {
      history_url += '?q=' + encodeURIComponent(query);
      if (scope_titles.length > 0) {
        history_url += '&scope=' + encodeURIComponent(scope_titles.join('/'));
      }
    }
  }

  // Build search title for history
  search_title = Connect.search_title;
  if (query) {
    search_title += ': ' + query;
  }

  // Update history - use replaceState since we're already in search mode
  Connect_Window.document.title = search_title;
  Connect_Window.history.replaceState(search_state, search_title, history_url);

  // Execute search with current scope
  Connect.HandleSearch();
};

Scope.SearchScopeCheckboxAreaClick = function (param_id) {
  'use strict';

  var checkbox;

  if (param_id) {
    // Need to undo the default 'checked' attribute
    // if the user clicks the checkbox because the
    // event for clicking the entire option runs
    // after this and takes care of the checked
    // attribute
    checkbox = document.getElementById(param_id);

    checkbox.checked = !checkbox.checked;
  }
};

Scope.SearchScopeOptionAreaClick = function (param_id) {
  'use strict';

  var checkbox;

  if (param_id) {
    // check/uncheck checkbox, run the entry function
    // to set up scope selections
    checkbox = document.getElementById(param_id);

    checkbox.checked = !checkbox.checked;
    Scope.SearchScopeCheckbox(param_id);
  }
};

Scope.SearchScopeParentSelection = function (param_id, param_checked) {
  'use strict';

  var checkboxes;

  checkboxes = document.querySelectorAll('#search_scope_options input[type=checkbox]');

  if (checkboxes) {
    for (var i = 0; i < checkboxes.length; i++) {
      var checkbox, checkboxId;

      checkbox = checkboxes[i];
      checkboxId = checkbox.getAttribute('id');

      if (checkboxId.split('_')[0] === param_id) {
        checkbox.checked = param_checked;
      }
    }
  }
};

Scope.SearchScopeChildSelection = function (param_id, param_checked) {
  'use strict';

  var checkboxes, ids_as_array, parent_id, parent_checkbox, sibling_checkboxes;

  checkboxes = document.querySelectorAll('#search_scope_options input[type=checkbox]');
  ids_as_array = param_id.split('_');
  parent_id = ids_as_array[0];
  parent_checkbox = document.getElementById(parent_id);

  if (param_checked) {
    var siblingsChecked;

    siblingsChecked = 0;
    sibling_checkboxes = [];

    // Find all siblings
    //
    for (var i = 0; i < checkboxes.length; i++) {
      var checkbox, checkboxId;

      checkbox = checkboxes[i];
      checkboxId = checkbox.getAttribute('id');

      if (checkboxId.indexOf(parent_id) === 0 && checkboxId !== parent_id) {
        sibling_checkboxes.push(checkbox);
      }
    }

    // Find how many siblings are checked
    //
    for (var i = 0; i < sibling_checkboxes.length; i++) {
      checkbox = sibling_checkboxes[i];

      if (checkbox.checked) {
        siblingsChecked += 1;
      }
    }

    if (siblingsChecked === sibling_checkboxes.length) {
      // All siblings checked, check the parent
      //
      parent_checkbox.checked = param_checked;
    }
  }
  else {
    // If you uncheck any child, uncheck the parent
    //
    parent_checkbox.checked = param_checked;
  }
};

Scope.UpdateSearchScopeSelections = function () {
  'use strict';

  var search_scope_checkboxes, search_scope_checkboxes_checked_count,
      search_scope_checkboxes_total_count;

  search_scope_checkboxes = document.querySelectorAll('#search_scope_options input[type=checkbox]');
  Scope.search_scope_selections = [];

  // Did we find the group of checkboxes?
  //
  if (search_scope_checkboxes) {
    search_scope_checkboxes_checked_count = 0;
    search_scope_checkboxes_total_count = search_scope_checkboxes.length;

    for (var i = 0; i < search_scope_checkboxes.length; i++) {
      var checkbox = search_scope_checkboxes[i];

      if (checkbox.checked === true) {
        search_scope_checkboxes_checked_count += 1;
        // Get the checkbox's id
        //
        var checkbox_id = checkbox.getAttribute('id');

        // Don't add children if the parent is present
        //
        if (Scope.search_scope_selections.indexOf(checkbox_id.split('_')[0]) === -1) {
          Scope.search_scope_selections.push(checkbox_id);
        }
      }
    }

    if (Scope.search_scope_selections.length === 0 ||
        search_scope_checkboxes_checked_count === search_scope_checkboxes_total_count) {
      Scope.search_scope_selections = ['all'];
    }
  }

  Scope.WriteSelectionsString();
};

Scope.WriteSelectionsString = function () {
  'use strict';

  var selections_string, selector_text_span, scope_selector_element;

  selector_text_span = document.getElementById('search_scope_value');
  scope_selector_element = document.getElementById('search_scope');

  selections_string = Scope.GetSearchScopeSelectionTitlesString();
  selector_text_span.innerHTML = selections_string;
  scope_selector_element.title = selections_string;
};

Scope.CheckCurrentSelectionCheckboxes = function () {
  'use strict';

  var search_scope_selections;

  search_scope_selections = Scope.search_scope_selections;

  for (var i = 0; i < search_scope_selections.length; i++) {
    var selection_id;

    selection_id = search_scope_selections[i];

    if (selection_id === 'all') {
      break;
    }
    else {
      // Only update checkbox visual state - do NOT call SearchScopeCheckbox
      // to avoid recursive loop when called from NavigateToSearch
      document.getElementById(selection_id).checked = true;
    }
  }
};

Scope.GetSearchScopeSelectionTitlesString = function () {
  'use strict';

  var selections_string, group_titles, search_scopes, search_scope_selections;

  selections_string = '';
  group_titles = [];
  search_scopes = Scope.search_scopes;
  search_scope_selections = Scope.search_scope_selections;

  for (var i = 0; i < search_scope_selections.length; i++) {
    var selection = search_scope_selections[i];

    if (selection === 'all') {
      group_titles.push(Connect.search_scope_all_label);
      break;
    }
    else {
      group_titles.push(search_scopes[selection].title);
    }
  }

  selections_string = group_titles.join(', ');

  return selections_string;
};

Scope.AddScopeOptions = function (param_document,
                                  param_parent_element,
                                  param_level,
                                  param_parent_prefix,
                                  param_search_scopes,
                                  param_children) {
  'use strict';

  var all_data_indexes, index, entry, option_element,
      option_level, option_title, option_value,
      entry_data_indexes, child_entries_data_indexes,
      child_entries_data_index;

  // Track all data indexes found at this level and below
  //
  all_data_indexes = [];
  for (index = 0; index < param_children.length; index += 1) {
    entry = param_children[index];

    option_level = String(param_level);
    option_value = param_parent_prefix + String(index);
    option_title = entry.title;

    option_element = [];
    option_element.push('<div class="ww_skin_search_scope_option" onclick="Scope.SearchScopeOptionAreaClick(\'' + option_value + '\')">');
    option_element.push('  <div class="ww_skin_search_scope_option_spacer group_level_' + option_level + '"></div>');
    option_element.push('  <div class="ww_skin_search_scope_input_cell">');
    option_element.push('    <input type="checkbox" id="' + option_value + '" value="' + option_value + '" onclick="Scope.SearchScopeCheckboxAreaClick(\'' + option_value + '\')"/>');
    option_element.push('  </div>');
    option_element.push('  <div class="ww_skin_search_scope_value_cell">');
    option_element.push('    <span>' + option_title + '</span>');
    option_element.push('  </div>');
    option_element.push('</div>');

    // Track selection
    param_search_scopes[option_value] = entry;
    param_parent_element.innerHTML += option_element.join("\n");

    // Define search urls
    //
    entry_data_indexes = [];
    if (entry.data_index !== undefined) {
      entry_data_indexes.push(entry.data_index);
      all_data_indexes.push(entry.data_index);
    }

    // Process children
    //
    if (entry.children !== undefined) {
      child_entries_data_indexes = Scope.AddScopeOptions(param_document, param_parent_element, param_level + 1, option_value + '_', param_search_scopes, entry.children);

      // Extend list of search urls to include all children
      //
      for (child_entries_data_index = 0; child_entries_data_index < child_entries_data_indexes.length; child_entries_data_index += 1) {
        entry_data_indexes.push(child_entries_data_indexes[child_entries_data_index]);
        all_data_indexes.push(child_entries_data_indexes[child_entries_data_index]);
      }
    }

    // Add to search scope map
    //
    Scope.search_scope_map[option_value] = entry_data_indexes;
  }

  return all_data_indexes;
};

Scope.RenderScopeSelector = function (param_document, param_search_scopes) {
  'use strict';

  var selector_element, all_data_indexes;

  selector_element = window.document.getElementById('search_scope_options');
  selector_element.innerHTML = '';

  // Reset search scope mapping
  //

  Scope.search_scope_map = {};
  all_data_indexes = Scope.AddScopeOptions(param_document, selector_element, 0, '', param_search_scopes, param_search_scopes);

  if (all_data_indexes.length <= 1) {
    Connect_Window.document.getElementById('search_scope_container').style.display = 'none';
  }

  // Add to search scope map
  //
  Scope.search_scope_map['all'] = all_data_indexes;
};

Scope.ToggleDropDown = function () {
  'use strict';

  var container_element, search_scope_button, options_open_class, options_closed_class;
  // selector_options_open selector_options_closed

  container_element = document.getElementById('search_scope_container');
  search_scope_button = document.getElementById('search_scope');
  options_open_class = 'selector_options_open';
  options_closed_class = 'selector_options_closed';

  if (Browser.ContainsClass(container_element.className, options_open_class)) {
    // hide the dropdown
    //
    container_element.className = Browser.RemoveClass(container_element.className, options_open_class);
    container_element.className = Browser.AddClass(container_element.className, options_closed_class);

    // Update aria-expanded state
    if (search_scope_button !== null) {
      search_scope_button.setAttribute('aria-expanded', 'false');
    }
  }
  else if (Browser.ContainsClass(container_element.className, options_closed_class)) {
    // show the dropdown
    //
    container_element.className = Browser.RemoveClass(container_element.className, options_closed_class);
    container_element.className = Browser.AddClass(container_element.className, options_open_class);

    // Update aria-expanded state
    if (search_scope_button !== null) {
      search_scope_button.setAttribute('aria-expanded', 'true');
    }
  }
};

Scope.CloseDropDown = function () {
  'use strict';

  var container_element, search_scope_button, options_open_class, options_closed_class;

  container_element = document.getElementById('search_scope_container');
  search_scope_button = document.getElementById('search_scope');
  options_open_class = 'selector_options_open';
  options_closed_class = 'selector_options_closed';

  container_element.className = Browser.RemoveClass(container_element.className, options_open_class);
  container_element.className = Browser.AddClass(container_element.className, options_closed_class);

  // Update aria-expanded state
  if (search_scope_button !== null) {
    search_scope_button.setAttribute('aria-expanded', 'false');
  }
};
