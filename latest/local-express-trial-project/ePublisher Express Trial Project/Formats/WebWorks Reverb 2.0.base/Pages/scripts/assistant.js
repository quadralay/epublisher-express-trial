/**
 * Assistant - WebWorks Reverb 2.0 implementation of a chat interface for AI assistants
 * Copyright (c) 2010-2024 Quadralay Corporation.  All rights reserved.
 *
 * ePublisher 2024.1
 */
'use strict';

// Assistant module for WebWorks Reverb 2.0
var Assistant = {
  container: null,
  assistant: {
    public_id: '',
    name: 'Reverb 2.0 Assistant',
    description: 'I can help you find information and answer questions about this documentation.',
    conversation_starters: [
      'What is WebWorks?',
      'How do I create a new document?',
      'What features are available in WebWorks Reverb?',
      'How do I customize my output?'
    ]
  },
  thread: { public_id: '', messages: [] },
  thread_id: '',
  message_text: '',
  latest_assistant_response: '',
  is_assistant_thinking: false,
  is_assistant_in_error: false,
  error_message: '',
  submitting: false,
  event_source: null,
  md: null,
  // IndexedDB properties
  db: null,
  current_local_thread_id: null,
  // Thread management properties
  view_mode: 'chat_view', // 'thread_list' | 'chat_view'
  available_threads: [],
  deleting_thread_ids: [],
  // Streaming aggregation
  working_evidence: [],
  stream_finalized: false
};

/**
 * Render the assistant chat interface
 */
function Assistant_Render() {
  // Create the main structure
  var html = '';

  html += '<div class="ww_skin_assistant_chat_container">';
  html += '  <div id="assistant_chat_area" class="ww_skin_assistant_chat_area">';
  html += Assistant_RenderMessages();
  html += Assistant_RenderLatestResponse();
  html += '  </div>';
  html += '  <div class="ww_skin_assistant_chat_input_area">';
  html += '    <form id="assistant_chat_form" class="ww_skin_assistant_chat_form">';
  html += '      <div class="ww_skin_assistant_chat_input_container ' + (Assistant.submitting ? 'submitting' : '') + '">';
  html += '        <div class="ww_skin_assistant_chat_textarea_wrapper">';
  html += '          <textarea id="user_chat_message" class="ww_skin_assistant_chat_textarea" ';
  html += '            placeholder="Ask ' + (Assistant.assistant.name || 'Untitled Assistant') + ' something..." ';
  html += (Assistant.submitting ? 'disabled' : '') + '></textarea>';
  html += '        </div>';
  html += '        <div class="ww_skin_assistant_chat_actions">';
  html += '          <div class="ww_skin_assistant_chat_actions_left">';
  html += '            <button type="button" id="delete_chat_button" class="ww_skin_assistant_chat_button ww_skin_assistant_ghost_button" ';
  html += '              title="Delete Chat" ' + (Assistant.submitting || !Assistant.current_local_thread_id ? 'disabled' : '') + '>';
  html += '              <i class="fa"></i>';
  html += '            </button>';
  html += '          </div>';
  html += '          <div class="ww_skin_assistant_chat_actions_right">';
  html += '            <button type="submit" id="send_message_button" class="ww_skin_assistant_chat_button ww_skin_assistant_primary_button';
  html += (Assistant.submitting ? ' ww_skin_assistant_chat_button_sending' : '');
  html += '" ' + (Assistant.submitting || Assistant.message_text === '' ? 'disabled' : '') + '>';

  if (Assistant.submitting) {
    html += '<i class="fa spin"></i> Sending';
  } else {
    html += '<i class="fa"></i> Send';
  }

  html += '            </button>';
  html += '          </div>';
  html += '        </div>';
  html += '      </div>';
  html += '    </form>';
  html += '  </div>';
  html += '</div>';

  Assistant.container.innerHTML = html;
}

/**
 * Render all messages in the chat
 * @returns {string} HTML for messages
 */
function Assistant_RenderMessages() {
  var messages, html, i, message;

  messages = Assistant.thread.messages || [];

  if (messages.length === 0) {
    return Assistant_RenderWelcomeScreen();
  }

  html = '';

  for (i = 0;i < messages.length;i++) {
    message = messages[i];

    if (message.role === 'user') {
      html += '<div class="ww_skin_assistant_message_row ww_skin_assistant_user_message">';
      html += '  <div class="ww_skin_assistant_message_avatar_container">';
      html += '    <!-- User avatar could go here -->';
      html += '  </div>';
      html += '  <div class="ww_skin_assistant_message_content_container">';
      html += '    <div class="ww_skin_assistant_user_bubble">';
      html += message.content_html;
      html += '    </div>';
      html += '  </div>';
      html += '</div>';
    } else if (message.role === 'assistant') {
      html += '<div class="ww_skin_assistant_message_row ww_skin_assistant_message">';
      html += '  <div class="ww_skin_assistant_message_avatar_container">';
      html += '    <div class="ww_skin_assistant_avatar">';
      html += '      <i class="fa"></i>';
      html += '    </div>';
      html += '  </div>';
      html += '  <div class="ww_skin_assistant_message_content_container">';

      // Render with evidence decoration if available; otherwise use provided HTML
      var rendered_html = message.content_html;
      if (Array.isArray(message.evidence) && message.evidence.length > 0 && typeof message.content === 'string') {
        try {
          var numbered = Assistant_NumberEvidence(message.evidence);
          var decorated = Assistant_DecorateWithEvidence(message.content, numbered);
          rendered_html = Assistant.md.render(decorated);
        } catch (e) {
          console.warn('Failed to render evidence, falling back to content_html:', e);
          rendered_html = message.content_html;
        }
      }

      html += '    <div class="ww_skin_assistant_bubble">';
      html += rendered_html;
      html += '    </div>';
      html += '  </div>';
      html += '</div>';
    }
  }

  return html;
}

/**
 * Render the welcome screen when no messages exist
 * @returns {string} HTML for welcome screen
 */
function Assistant_RenderWelcomeScreen() {
  var html, i, starters, starter;

  html = '<div class="ww_skin_assistant_welcome_screen">';
  html += '  <div class="ww_skin_assistant_avatar">';
  html += '    <i class="fa"></i>';
  html += '  </div>';
  html += '  <h1 class="ww_skin_assistant_welcome_title">' + (Assistant.assistant.name || 'Untitled Assistant') + '</h1>';
  html += '  <p class="ww_skin_assistant_welcome_description">' + (Assistant.assistant.description || 'No description provided.') + '</p>';
  html += '  <div class="ww_skin_assistant_conversation_starters">';

  starters = Assistant.assistant.conversation_starters || [];
  for (i = 0;i < starters.length;i++) {
    starter = starters[i];
    if (starter) {
      html += '<button class="ww_skin_assistant_starter_button" data-starter="' + Assistant_EscapeHtml(starter) + '">';
      html += starter;
      html += '</button>';
    }
  }

  html += '  </div>';
  html += '</div>';

  return html;
}

/**
 * Render the latest response from the assistant
 * @returns {string} HTML for latest response
 */
function Assistant_RenderLatestResponse() {
  var html = '';

  if (Assistant.is_assistant_thinking) {
    html += '<div class="ww_skin_assistant_message_row ww_skin_assistant_message">';
    html += '  <div class="ww_skin_assistant_message_avatar_container">';
    html += '    <div class="ww_skin_assistant_avatar">';
    html += '      <i class="fa"></i>';
    html += '    </div>';
    html += '  </div>';
    html += '  <div class="ww_skin_assistant_message_content_container">';
    html += '    <div class="ww_skin_assistant_thinking_indicator">';
    html += '      <i class="fa spin"></i>';
    html += '    </div>';
    html += '  </div>';
    html += '</div>';
  } else if (Assistant.is_assistant_in_error) {
    html += '<div class="ww_skin_assistant_message_row ww_skin_assistant_message">';
    html += '  <div class="ww_skin_assistant_message_avatar_container">';
    html += '    <div class="ww_skin_assistant_avatar">';
    html += '      <i class="fa"></i>';
    html += '    </div>';
    html += '  </div>';
    html += '  <div class="ww_skin_assistant_message_content_container">';
    html += '    <div class="ww_skin_assistant_error_message">';
    html += '      <span>' + Assistant.error_message + '</span>';
    html += '    </div>';
    html += '  </div>';
    html += '</div>';
  } else if (Assistant.latest_assistant_response !== '') {
    html += '<div class="ww_skin_assistant_message_row ww_skin_assistant_message">';
    html += '  <div class="ww_skin_assistant_message_avatar_container">';
    html += '    <div class="ww_skin_assistant_avatar">';
    html += '      <i class="fa"></i>';
    html += '    </div>';
    html += '  </div>';
    html += '  <div class="ww_skin_assistant_message_content_container">';
    html += '    <div class="ww_skin_assistant_bubble">';
    html += Assistant.md.render(Assistant.latest_assistant_response);
    html += '    </div>';
    html += '  </div>';
    html += '</div>';
  }

  return html;
}

/**
 * Set up all event listeners for the chat interface
 */
function Assistant_SetupEventListeners() {
  var form, delete_button, textarea, starter_buttons, input_container;

  // Form submission
  form = Assistant.container.querySelector('#assistant_chat_form');
  if (form) {
    form.addEventListener('submit', Assistant_HandleFormSubmit);
  }

  // Delete chat button
  delete_button = Assistant.container.querySelector('#delete_chat_button');
  if (delete_button) {
    delete_button.addEventListener('click', Assistant_HandleDeleteChat);
  }

  // Textarea input and keydown
  textarea = Assistant.container.querySelector('#user_chat_message');
  if (textarea) {
    textarea.addEventListener('input', function (param_event) {
      Assistant.message_text = param_event.target.value;
      Assistant_UpdateUserControlsState();
    });

    textarea.addEventListener('keydown', Assistant_HandleKeydown);
  }

  // Input container click to focus textarea
  input_container = Assistant.container.querySelector('.ww_skin_assistant_chat_input_container');
  if (input_container) {
    input_container.addEventListener('click', function (param_event) {
      var textarea_element = Assistant.container.querySelector('#user_chat_message');

      // Don't focus if clicking on buttons or textarea itself
      if (param_event.target.tagName === 'BUTTON' ||
        param_event.target.tagName === 'TEXTAREA' ||
        param_event.target.closest('button')) {
        return;
      }

      // Focus textarea if it's not disabled
      if (textarea_element && !textarea_element.disabled) {
        textarea_element.focus();
      }
    });
  }

  // Conversation starter buttons
  starter_buttons = Assistant.container.querySelectorAll('.ww_skin_assistant_starter_button');
  starter_buttons.forEach(function (param_button) {
    param_button.addEventListener('click', function (param_event) {
      var starter = param_event.target.getAttribute('data-starter');
      var textarea;

      if (starter) {
        textarea = Assistant.container.querySelector('#user_chat_message');
        if (textarea) {
          textarea.value = starter;
          Assistant.message_text = starter;
          Assistant_UpdateUserControlsState();
          textarea.focus();
        }
      }
    });
  });

  // Back button (if in chat view)
  var back_button = Assistant.container.querySelector('#chat_back_button');
  if (back_button) {
    back_button.addEventListener('click', function () {
      Assistant_ShowThreadListView();
    });
  }
}

/**
 * Update the state of the send button based on current conditions
 */
function Assistant_UpdateSendButtonState() {
  var send_button = Assistant.container.querySelector('#send_message_button');
  if (send_button) {
    if (Assistant.submitting || Assistant.message_text === '') {
      send_button.setAttribute('disabled', '');
    } else {
      send_button.removeAttribute('disabled');
    }

    // Toggle the sending class
    if (Assistant.submitting) {
      send_button.classList.add('ww_skin_assistant_chat_button_sending');
    } else {
      send_button.classList.remove('ww_skin_assistant_chat_button_sending');
    }

    send_button.innerHTML = Assistant.submitting ?
      '<i class="fa spin"></i> Sending' :
      '<i class="fa"></i> Send';
  }
}

/**
 * Update the state of the input area (textarea and container)
 */
function Assistant_UpdateInputAreaState() {
  var textarea = Assistant.container.querySelector('#user_chat_message');
  var input_container = Assistant.container.querySelector('.ww_skin_assistant_chat_input_container');

  if (textarea) {
    if (Assistant.submitting) {
      textarea.setAttribute('disabled', '');
    } else {
      textarea.removeAttribute('disabled');
    }
  }

  if (input_container) {
    if (Assistant.submitting) {
      input_container.classList.add('submitting');
    } else {
      input_container.classList.remove('submitting');
    }
  }
}

/**
 * Update the state of the delete chat button
 */
function Assistant_UpdateDeleteButtonState() {
  var delete_button = Assistant.container.querySelector('#delete_chat_button');

  if (delete_button) {
    if (Assistant.submitting || !Assistant.current_local_thread_id) {
      delete_button.setAttribute('disabled', '');
    } else {
      delete_button.removeAttribute('disabled');
    }
  }
}

/**
 * Update all user control states (send button, input area, delete chat button)
 */
function Assistant_UpdateUserControlsState() {
  Assistant_UpdateSendButtonState();
  Assistant_UpdateInputAreaState();
  Assistant_UpdateDeleteButtonState();
}

/**
 * Handle form submission
 * @param {Event} param_event - The submit event
 */
function Assistant_HandleFormSubmit(param_event) {
  param_event.preventDefault();

  if (Assistant.submitting || Assistant.message_text === '') {
    return;
  }

  Assistant_SendMessage(Assistant.message_text);
}

/**
 * Handle keydown events in the textarea
 * @param {KeyboardEvent} param_event - The keydown event
 */
function Assistant_HandleKeydown(param_event) {
  if (param_event.key === 'Enter' && !param_event.shiftKey) {
    param_event.preventDefault();

    if (!Assistant.submitting && Assistant.message_text !== '') {
      Assistant_SendMessage(Assistant.message_text);
    }
  }
}

/**
 * Send a message to the assistant
 * @param {string} param_message - The message to send
 */
function Assistant_SendMessage(param_message) {
  var message_text, user_message, textarea, api_url, request_data;

  Assistant.submitting = true;
  Assistant_UpdateUserControlsState();

  message_text = param_message + '\n\n';
  message_text += '<!-- 💻 USER PAGE CONTEXT 💻 \n\n';
  message_text += Navigation.page_info.text_content;
  message_text += '\n\n-->';

  // Create user message and add to UI immediately
  user_message = {
    role: 'user',
    content_html: Assistant.md.render(message_text),
    content: message_text,
    timestamp: Date.now()
  };

  // Add user message to thread
  if (!Assistant.thread.messages) {
    Assistant.thread.messages = [];
  }

  Assistant.thread.messages.push(user_message);

  // Clear the input field
  textarea = Assistant.container.querySelector('#user_chat_message');
  if (textarea) {
    textarea.value = '';
    Assistant.message_text = '';
  }

  // Update UI to show the user message
  Assistant_Render();
  Assistant_SetupEventListeners();
  Assistant_ScrollConversationToBottom();

  // Prepare API request
  api_url = 'https://platform.webworks.com/api/reverb2/assistants/' + encodeURIComponent(Assistant.assistant.public_id) + '/chat';
  request_data = {
    messages: Assistant.thread.messages
  };

  // Make the real API call
  fetch(api_url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(request_data)
  })
    .then(function (response) {
      if (!response.ok) {
        throw new Error('HTTP ' + response.status + ': ' + response.statusText);
      }
      return response.json();
    })
    .then(function (thread_data) {
      // Update thread with server's source of truth
      Assistant.thread = thread_data;
      Assistant.thread_id = thread_data.public_id;

      // Clear latest_assistant_response for new streaming
      Assistant.latest_assistant_response = '';

      console.log('Message sent successfully, thread_id:', Assistant.thread_id);

      // Re-render conversation from server data
      Assistant_Render();
      Assistant_SetupEventListeners();
      Assistant_ScrollConversationToBottom();

      // Start the real assistant response stream
      Assistant_StartAssistantResponseStream();
    })
    .catch(function (error) {
      console.error('Error sending message:', error);
      Assistant_HandleMessageSendError(param_message, error);
    });
}

/**
 * Handle deleting the current chat
 */
function Assistant_HandleDeleteChat() {
  if (Assistant.submitting || !Assistant.current_local_thread_id) {
    return;
  }

  // Use the same delete logic as the thread list view
  Assistant_DeleteThreadItem(Assistant.current_local_thread_id);
}

/**
 * Start streaming the assistant response
 */
function Assistant_StartAssistantResponseStream() {
  var stream_url;

  // Reset streaming state
  Assistant.latest_assistant_response = '';
  Assistant.is_assistant_thinking = true;
  Assistant.is_assistant_in_error = false;
  // Reset working evidence and finalize flag
  Assistant.working_evidence = [];
  Assistant.stream_finalized = false;

  // Close any existing EventSource
  if (Assistant.event_source) {
    Assistant.event_source.close();
    Assistant.event_source = null;
  }

  // Update the UI to show thinking state
  Assistant_RenderLatestResponseToDOM();
  Assistant_ScrollConversationToBottom();

  console.log('Starting real assistant response stream for thread:', Assistant.thread_id);

  // Create EventSource URL
  stream_url = 'https://platform.webworks.com/api/reverb2/assistants/' +
    encodeURIComponent(Assistant.assistant.public_id) +
    '/threads/' + encodeURIComponent(Assistant.thread_id) + '/stream';

  console.log('Connecting to stream:', stream_url);

  // Set up EventSource
  Assistant.event_source = new EventSource(stream_url);

  // Handle streaming events
  Assistant.event_source.onmessage = function (event) {
    var data;

    try {
      data = JSON.parse(event.data);
    } catch (error) {
      console.error('Error parsing stream data:', error);
      Assistant_HandleStreamError({ content: 'Error parsing response data' });
      return;
    }

    if (data.type === 'error') {
      // Handle streaming error
      console.error('Stream error:', data);
      Assistant_HandleStreamError(data);
      return;
    }

    if (data.type === 'warning') {
      // These can be skipped
      return;
    }

    if (data.type === 'evidence') {
      // Evidence arrives from after_final_emit; parse and finalize
      try {
        var ev = JSON.parse(data.content);
        Assistant.working_evidence = Array.isArray(ev) ? ev : [];
      } catch (e) {
        console.warn('Failed to parse evidence event:', e);
        Assistant.working_evidence = [];
      }
      Assistant_FinalizeStreamMessage();
      return;
    }

    if (data.type === 'done') {
      // Stream complete - finalize if we haven't already
      console.log('Stream completed');
      if (!Assistant.stream_finalized) {
        Assistant_CompleteStream();
      }
      return;
    }

    // Append content deltas and update UI
    if (typeof data.content === 'string' && (data.type === 'response.output_text.delta' || data.type === 'delta' || data.type === 'message' || !data.type)) {
      Assistant.latest_assistant_response += data.content;
      Assistant.is_assistant_thinking = false;
      Assistant_RenderLatestResponseToDOM();
      Assistant_ScrollConversationToBottom();
      return;
    }

    // Ignore other event types
  };

  // Handle connection errors
  Assistant.event_source.onerror = function (event) {
    console.error('EventSource connection error:', event);
    Assistant_HandleStreamError({ content: 'Connection error during streaming' });
  };

  // Setup cleanup for page navigation
  window.addEventListener('beforeunload', Assistant_CleanupEventSource);
}

/**
 * Parse an action result from JSON or HTML
 * @param {string} param_result_text - The text to parse
 * @returns {Object} The parsed result
 */
function Assistant_ParseActionResult(param_result_text) {
  var payload, data_match;

  // This is a simplified version of SvelteKit's deserialize function
  try {
    payload = JSON.parse(param_result_text);
    return payload;
  } catch (e) {
    // For text/html responses
    data_match = param_result_text.match(/<script type="application\/json" data-sveltekit-fetched data-url="[^"]*">([^<]*)<\/script>/);
    if (data_match) {
      try {
        payload = JSON.parse(decodeURIComponent(data_match[1]));
        return payload;
      } catch (e) {
        console.error('Failed to parse action result', e);
      }
    }
    return { type: 'error', error: 'Failed to parse response' };
  }
}

/**
 * Render the latest response to the DOM
 */
/**
 * Number evidence items in-order and return a shallow-copied array with _ref numbers.
 * Evidence item shape:
 *   { filename?: string, ids?: string[], message_span?: { start:number, end:number }, message_index?: number }
 */
function Assistant_NumberEvidence(param_evidence) {
  try {
    var arr = Array.isArray(param_evidence) ? param_evidence.slice() : [];
    arr.sort(function (a, b) {
      var apos = (a && a.message_span && typeof a.message_span.start === 'number')
        ? a.message_span.start
        : (a && typeof a.message_index === 'number')
          ? a.message_index
          : Number.POSITIVE_INFINITY;

      var bpos = (b && b.message_span && typeof b.message_span.start === 'number')
        ? b.message_span.start
        : (b && typeof b.message_index === 'number')
          ? b.message_index
          : Number.POSITIVE_INFINITY;

      if (apos !== bpos) return apos - bpos;
      var af = (a && a.filename ? String(a.filename) : '').toLowerCase();
      var bf = (b && b.filename ? String(b.filename) : '').toLowerCase();
      if (af !== bf) return af.localeCompare(bf);
      return 0;
    });
    return arr.map(function (e, i) {
      var copy = {};
      for (var k in e) {
        if (Object.prototype.hasOwnProperty.call(e, k)) copy[k] = e[k];
      }
      copy._ref = i + 1;
      return copy;
    });
  } catch (err) {
    console.warn('Assistant_NumberEvidence failed:', err);
    return Array.isArray(param_evidence) ? param_evidence : [];
  }
}

/**
 * Resolve a usable landmark id for an evidence entry using Landmarks.data['by-id'].
 * Selection rule: choose the LAST id in e.ids that exists in by-id (reverse scan).
 * Returns { raw: "#id", clean: "id" } or null if not found.
 */
function Assistant_SelectLandmarkId(e) {
  try {
    var landmarks = (typeof window !== 'undefined' && window.Landmarks && window.Landmarks.data && window.Landmarks.data['by-id'])
      ? window.Landmarks.data['by-id']
      : null;
    if (!landmarks || !e || !Array.isArray(e.ids) || e.ids.length === 0) return null;
    for (var i = e.ids.length - 1;i >= 0;i--) {
      var raw = e.ids[i];
      if (!raw || typeof raw !== 'string') continue;
      var clean = raw.charAt(0) === '#' ? raw.slice(1) : raw;
      if (Object.prototype.hasOwnProperty.call(landmarks, raw) || Object.prototype.hasOwnProperty.call(landmarks, clean)) {
        return { raw: raw, clean: clean };
      }
    }
    return null;
  } catch (err) {
    console.warn('Assistant_SelectLandmarkId failed:', err);
    return null;
  }
}

/**
 * Filter evidence to only those entries that resolve to a known landmark id.
 * Adds e._landmark = { raw, clean } for matched items.
 * If Landmarks.data['by-id'] is missing, returns [] (skip all markers).
 */
function Assistant_FilterEvidenceWithLandmarks(arr) {
  try {
    var landmarks = (typeof window !== 'undefined' && window.Landmarks && window.Landmarks.data && window.Landmarks.data['by-id'])
      ? window.Landmarks.data['by-id']
      : null;
    if (!landmarks) return [];
    var out = [];
    for (var i = 0;i < (arr || []).length;i++) {
      var e = arr[i];
      var sel = Assistant_SelectLandmarkId(e);
      if (sel) {
        var copy = {};
        for (var k in e) if (Object.prototype.hasOwnProperty.call(e, k)) copy[k] = e[k];
        copy._landmark = sel;
        out.push(copy);
      }
    }
    return out;
  } catch (err) {
    console.warn('Assistant_FilterEvidenceWithLandmarks failed:', err);
    return [];
  }
}

/**
 * Decorate raw assistant text with evidence spans and caret markers, then return HTML-ready string.
 * - Wrap ranges with <span class="evidence-chip" data-ref="N">...</span>
 * - Insert caret as <span class="evidence-caret"></span>
 * - After a closed span/caret, append superscript link: <sup><a href="#/<landmark_id>" class="evidence-ref" data-ref="N">[N]</a></sup>
 * Note: Links point to "#/<clean>" where clean is the id without leading "#".
 * We expect evidence to be pre-filtered so each entry has _landmark; if not, link is skipped.
 */
function Assistant_DecorateWithEvidence(text, evidence) {
  if (!text || !Array.isArray(evidence) || evidence.length === 0) return text;

  var markers = [];
  var evidenceByRef = {};
  for (var i = 0;i < evidence.length;i++) {
    var e = evidence[i];
    var ref = (e && typeof e._ref === 'number') ? e._ref : null;
    if (typeof ref === 'number') {
      evidenceByRef[ref] = e;
    }

    if (e && e.message_span && typeof e.message_span.start === 'number' && typeof e.message_span.end === 'number') {
      var s = Math.max(0, Math.min(text.length, e.message_span.start));
      var ed = Math.max(s, Math.min(text.length, e.message_span.end));
      if (ed > s) {
        markers.push({ pos: s, type: 'open', ref: ref });
        markers.push({ pos: ed, type: 'close', ref: ref });
      }
    } else if (e && typeof e.message_index === 'number') {
      var p = Math.max(0, Math.min(text.length, e.message_index));
      markers.push({ pos: p, type: 'caret', ref: ref });
    }
  }

  if (markers.length === 0) return text;

  // Sort by position; at same pos: close before caret before open
  markers.sort(function (a, b) {
    if (a.pos !== b.pos) return a.pos - b.pos;
    var order = { close: 0, caret: 1, open: 2 };
    return order[a.type] - order[b.type];
  });

  var out = '';
  var cursor = 0;
  var stack = [];

  for (var j = 0;j < markers.length;j++) {
    var m = markers[j];

    if (m.pos > cursor) {
      out += text.slice(cursor, m.pos);
      cursor = m.pos;
    }

    if (m.type === 'close') {
      if (stack.length) {
        out += '</span>';
        stack.pop();
      }
      if (typeof m.ref === 'number') {
        var eref = evidenceByRef[m.ref];
        var href = (eref && eref._landmark && typeof eref._landmark.clean === 'string') ? ('#/' + eref._landmark.clean) : null;
        if (href) {
          out += '<sup><a href="' + href + '" class="evidence-ref" data-ref="' + m.ref + '">[' + m.ref + ']</a></sup>';
        }
      }
    } else if (m.type === 'caret') {
      out += '<span class="evidence-caret"></span>';
      if (typeof m.ref === 'number') {
        var eref2 = evidenceByRef[m.ref];
        var href2 = (eref2 && eref2._landmark && typeof eref2._landmark.clean === 'string') ? ('#/' + eref2._landmark.clean) : null;
        if (href2) {
          out += '<sup><a href="' + href2 + '" class="evidence-ref" data-ref="' + m.ref + '">[' + m.ref + ']</a></sup>';
        }
      }
    } else if (m.type === 'open') {
      out += '<span class="evidence-chip' + '"' + (typeof m.ref === 'number' ? ' data-ref="' + m.ref + '"' : '') + '>';
      stack.push('evidence-chip');
    }
  }

  if (cursor < text.length) {
    out += text.slice(cursor);
  }
  while (stack.length) {
    out += '</span>';
    stack.pop();
  }

  return out;
}

function Assistant_RenderLatestResponseToDOM() {
  var chat_area, messages, new_content;

  chat_area = Assistant.container.querySelector('#assistant_chat_area');
  if (!chat_area) return;

  // Get all existing messages
  messages = Assistant.thread.messages || [];

  // Create a new chat area content
  new_content = Assistant_RenderMessages() + Assistant_RenderLatestResponse();

  // Update the chat area
  chat_area.innerHTML = new_content;
}

/**
 * Scroll the conversation to the bottom
 */
function Assistant_ScrollConversationToBottom() {
  var conversation_area = Assistant.container.querySelector('#assistant_chat_area');
  if (conversation_area) {
    conversation_area.scrollTop = conversation_area.scrollHeight;
  }
}

/**
 * Escape HTML to prevent XSS
 * @param {string} param_html - The HTML to escape
 * @returns {string} The escaped HTML
 */
function Assistant_EscapeHtml(param_html) {
  var div = document.createElement('div');
  div.textContent = param_html;
  return div.innerHTML;
}

/**
 * Generate a UUID v4
 * @returns {string} UUID string
 */
function Assistant_GenerateUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

/**
 * Generate a thread title from the first user message
 * @param {string} param_first_message - The first user message
 * @returns {string} Generated title
 */
function Assistant_GenerateThreadTitle(param_first_message) {
  var title = param_first_message || 'New Conversation';

  // Truncate to 50 characters max
  if (title.length > 50) {
    title = title.substring(0, 47) + '...';
  }

  return title;
}

/**
 * Initialize IndexedDB for conversation storage
 * @returns {Promise} Promise that resolves when DB is ready
 */
function Assistant_InitializeDB() {
  return new Promise(function (resolve, reject) {
    var request = indexedDB.open('reverb_assistant_conversations', 1);

    request.onerror = function () {
      console.error('Failed to open IndexedDB:', request.error);
      reject(request.error);
    };

    request.onsuccess = function () {
      Assistant.db = request.result;
      console.log('IndexedDB initialized successfully');
      resolve(Assistant.db);
    };

    request.onupgradeneeded = function () {
      var db = request.result;

      // Create the threads object store
      if (!db.objectStoreNames.contains('threads')) {
        var store = db.createObjectStore('threads', { keyPath: 'id' });

        // Create indexes for efficient querying
        store.createIndex('assistant_public_id', 'assistant_public_id', { unique: false });
        store.createIndex('updated_at', 'updated_at', { unique: false });

        console.log('Created threads object store');
      }
    };
  });
}

/**
 * Save a thread to IndexedDB
 * @param {Object} param_thread_data - Thread data to save
 * @returns {Promise} Promise that resolves when saved
 */
function Assistant_SaveThread(param_thread_data) {
  return new Promise(function (resolve, reject) {
    if (!Assistant.db) {
      reject(new Error('Database not initialized'));
      return;
    }

    var transaction = Assistant.db.transaction(['threads'], 'readwrite');
    var store = transaction.objectStore('threads');

    // Prepare thread data for storage
    var thread_to_save = {
      id: param_thread_data.id || Assistant_GenerateUUID(),
      assistant_public_id: Assistant.assistant.public_id,
      title: param_thread_data.title || Assistant_GenerateThreadTitle(
        param_thread_data.messages && param_thread_data.messages.length > 0 ?
          param_thread_data.messages[0].content : 'New Conversation'
      ),
      created_at: param_thread_data.created_at || Date.now(),
      updated_at: Date.now(),
      message_count: param_thread_data.messages ? param_thread_data.messages.length : 0,
      last_message_preview: Assistant_GetLastMessagePreview(param_thread_data.messages),
      messages: param_thread_data.messages || []
    };

    var request = store.put(thread_to_save);

    request.onsuccess = function () {
      console.log('Thread saved to IndexedDB:', thread_to_save.id);
      resolve(thread_to_save);
    };

    request.onerror = function () {
      console.error('Failed to save thread:', request.error);
      reject(request.error);
    };
  });
}

/**
 * Load all threads for the current assistant
 * @returns {Promise} Promise that resolves with array of threads
 */
function Assistant_LoadThreads() {
  return new Promise(function (resolve, reject) {
    if (!Assistant.db) {
      reject(new Error('Database not initialized'));
      return;
    }

    var transaction = Assistant.db.transaction(['threads'], 'readonly');
    var store = transaction.objectStore('threads');
    var index = store.index('assistant_public_id');
    var request = index.getAll(Assistant.assistant.public_id);

    request.onsuccess = function () {
      var threads = request.result || [];

      // Sort by updated_at descending (most recent first)
      threads.sort(function (a, b) {
        return b.updated_at - a.updated_at;
      });

      console.log('Loaded threads from IndexedDB:', threads.length);
      resolve(threads);
    };

    request.onerror = function () {
      console.error('Failed to load threads:', request.error);
      reject(request.error);
    };
  });
}

/**
 * Load a specific thread by ID
 * @param {string} param_thread_id - Thread ID to load
 * @returns {Promise} Promise that resolves with thread data
 */
function Assistant_LoadThread(param_thread_id) {
  return new Promise(function (resolve, reject) {
    if (!Assistant.db) {
      reject(new Error('Database not initialized'));
      return;
    }

    var transaction = Assistant.db.transaction(['threads'], 'readonly');
    var store = transaction.objectStore('threads');
    var request = store.get(param_thread_id);

    request.onsuccess = function () {
      var thread = request.result;
      if (thread) {
        console.log('Loaded thread from IndexedDB:', param_thread_id);
        resolve(thread);
      } else {
        reject(new Error('Thread not found'));
      }
    };

    request.onerror = function () {
      console.error('Failed to load thread:', request.error);
      reject(request.error);
    };
  });
}

/**
 * Delete a thread from IndexedDB
 * @param {string} param_thread_id - Thread ID to delete
 * @returns {Promise} Promise that resolves when deleted
 */
function Assistant_DeleteThread(param_thread_id) {
  return new Promise(function (resolve, reject) {
    if (!Assistant.db) {
      reject(new Error('Database not initialized'));
      return;
    }

    var transaction = Assistant.db.transaction(['threads'], 'readwrite');
    var store = transaction.objectStore('threads');
    var request = store.delete(param_thread_id);

    request.onsuccess = function () {
      console.log('Thread deleted from IndexedDB:', param_thread_id);
      resolve();
    };

    request.onerror = function () {
      console.error('Failed to delete thread:', request.error);
      reject(request.error);
    };
  });
}

/**
 * Get a preview of the last message in a thread
 * @param {Array} param_messages - Array of messages
 * @returns {string} Preview text
 */
function Assistant_GetLastMessagePreview(param_messages) {
  if (!param_messages || param_messages.length === 0) {
    return '';
  }

  var last_message = param_messages[param_messages.length - 1];
  var content = last_message.content || last_message.content_html || '';

  // Strip HTML tags and truncate to 100 characters
  content = content.replace(/<[^>]*>/g, '');
  if (content.length > 100) {
    content = content.substring(0, 97) + '...';
  }

  return content;
}

/**
 * Save the current conversation to IndexedDB after stream completion
 * @returns {Promise} Promise that resolves with saved thread data
 */
function Assistant_SaveConversationAfterStream() {
  // Prepare the thread data for saving
  var thread_data = {
    id: Assistant.current_local_thread_id, // Will be null for new conversations
    messages: Assistant.thread.messages || [],
    created_at: Assistant.current_local_thread_id ? undefined : Date.now() // Only set for new threads
  };

  return Assistant_SaveThread(thread_data);
}

/**
 * Format a timestamp as MM/DD/YYYY
 * @param {number} param_timestamp - Timestamp to format
 * @returns {string} Formatted date string
 */
function Assistant_FormatDate(param_timestamp) {
  var date = new Date(param_timestamp);
  var month = (date.getMonth() + 1).toString().padStart(2, '0');
  var day = date.getDate().toString().padStart(2, '0');
  var year = date.getFullYear();

  return month + '/' + day + '/' + year;
}

/**
 * Show the thread list view
 */
function Assistant_ShowThreadListView() {
  Assistant.view_mode = 'thread_list';

  // Load threads from IndexedDB
  Assistant_LoadThreads()
    .then(function (threads) {
      Assistant.available_threads = threads;

      if (threads.length === 0) {
        // No threads, show new chat view
        Assistant_ShowNewChatView();
      } else {
        // Render thread list
        Assistant_RenderThreadListView();
        Assistant_SetupThreadListEventListeners();
      }
    })
    .catch(function (error) {
      console.error('Failed to load threads:', error);
      // Fall back to new chat view
      Assistant_ShowNewChatView();
    });
}

/**
 * Show the chat view for a specific thread
 * @param {string} param_thread_id - Thread ID to load
 */
function Assistant_ShowChatView(param_thread_id) {
  Assistant.view_mode = 'chat_view';

  // Load the thread from IndexedDB
  Assistant_LoadThread(param_thread_id)
    .then(function (thread_data) {
      // Set up the thread data
      Assistant.current_local_thread_id = thread_data.id;
      Assistant.thread = {
        public_id: '', // Server thread ID will be empty for local threads
        messages: thread_data.messages || []
      };
      Assistant.thread_id = '';

      // Render chat view
      Assistant_RenderChatView();
      Assistant_SetupEventListeners();
      Assistant_ScrollConversationToBottom();
    })
    .catch(function (error) {
      console.error('Failed to load thread:', error);
      // Fall back to thread list
      Assistant_ShowThreadListView();
    });
}

/**
 * Show the new chat view (welcome screen)
 */
function Assistant_ShowNewChatView() {
  Assistant.view_mode = 'chat_view';

  // Reset thread state for new conversation
  Assistant.current_local_thread_id = null;
  Assistant.thread = { public_id: '', messages: [] };
  Assistant.thread_id = '';
  Assistant.message_text = '';

  // Clear any streaming state
  Assistant.latest_assistant_response = '';
  Assistant.is_assistant_thinking = false;
  Assistant.is_assistant_in_error = false;
  Assistant.error_message = '';
  Assistant.submitting = false;

  // Close any active EventSource
  if (Assistant.event_source) {
    Assistant.event_source.close();
    Assistant.event_source = null;
  }

  // Render new chat view
  Assistant_RenderChatView();
  Assistant_SetupEventListeners();
}

/**
 * Delete a thread with UI feedback
 * @param {string} param_thread_id - Thread ID to delete
 */
function Assistant_DeleteThreadItem(param_thread_id) {
  // Add to deleting list to grey out the item
  if (Assistant.deleting_thread_ids.indexOf(param_thread_id) === -1) {
    Assistant.deleting_thread_ids.push(param_thread_id);
  }

  // Re-render to show greyed out state
  Assistant_RenderThreadListView();
  Assistant_SetupThreadListEventListeners();

  // Delete from IndexedDB
  Assistant_DeleteThread(param_thread_id)
    .then(function () {
      // Remove from deleting list
      var index = Assistant.deleting_thread_ids.indexOf(param_thread_id);
      if (index > -1) {
        Assistant.deleting_thread_ids.splice(index, 1);
      }

      // Remove from available threads
      Assistant.available_threads = Assistant.available_threads.filter(function (thread) {
        return thread.id !== param_thread_id;
      });

      // Check if we have any threads left
      if (Assistant.available_threads.length === 0) {
        // No threads left, go to new chat view
        Assistant_ShowNewChatView();
      } else {
        // Re-render thread list
        Assistant_RenderThreadListView();
        Assistant_SetupThreadListEventListeners();
      }
    })
    .catch(function (error) {
      console.error('Failed to delete thread:', error);

      // Remove from deleting list to restore the item
      var index = Assistant.deleting_thread_ids.indexOf(param_thread_id);
      if (index > -1) {
        Assistant.deleting_thread_ids.splice(index, 1);
      }

      // Re-render to restore the item
      Assistant_RenderThreadListView();
      Assistant_SetupThreadListEventListeners();
    });
}

/**
 * Initialize the Assistant component with default data
 * @param {HTMLElement} param_container - The container element
 * @returns {Object} The Assistant context
 */
function Assistant_Initialize(param_container) {
  // Initialize markdown renderer
  Assistant.md = window.markdownit({
    html: true
  });

  // Set container
  Assistant.container = param_container;

  // Get public_id from hidden input
  Assistant.assistant.public_id = document.querySelector('#ai_assistant_id')?.value;

  // Show loading state initially
  Assistant_ShowLoadingState();

  // Initialize IndexedDB first
  Assistant_InitializeDB()
    .then(function () {
      // Try to fetch assistant data from API if we have a public_id
      if (Assistant.assistant.public_id && Assistant.assistant.public_id.trim() !== '') {
        return Assistant_FetchAssistantData(Assistant.assistant.public_id);
      } else {
        console.warn('No assistant public_id found, using default data');
        return null;
      }
    })
    .then(function (api_data) {
      if (api_data) {
        // Update assistant data with API response
        Assistant_UpdateAssistantData(api_data);
      }
      Assistant_InitializeUI();
    })
    .catch(function (error) {
      console.warn('Failed to initialize assistant:', error);
      // Fall back to default behavior without IndexedDB
      Assistant_InitializeUI();
    });

  return Assistant;
}

/**
 * Show loading state in the assistant container
 */
function Assistant_ShowLoadingState() {
  var html = '';

  html += '<div class="ww_skin_assistant_loading_container">';
  html += '  <div class="ww_skin_assistant_loading_content">';
  html += '    <i class="fa spin ww_skin_assistant_loading_spinner"></i>';
  html += '    <h1 class="ww_skin_assistant_welcome_title">Loading Assistant...</h1>';
  html += '    <p class="ww_skin_assistant_welcome_description">Please wait while we set up your AI assistant.</p>';
  html += '  </div>';
  html += '</div>';

  Assistant.container.innerHTML = html;
}

/**
 * Fetch assistant data from the API
 * @param {string} param_public_id - The assistant public ID
 * @returns {Promise} Promise that resolves with assistant data
 */
function Assistant_FetchAssistantData(param_public_id) {
  return new Promise(function (resolve, reject) {
    var api_url = 'https://platform.webworks.com/api/reverb2/assistants/' + encodeURIComponent(param_public_id);

    fetch(api_url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    })
      .then(function (response) {
        if (!response.ok) {
          throw new Error('HTTP ' + response.status + ': ' + response.statusText);
        }
        return response.json();
      })
      .then(function (data) {
        resolve(data);
      })
      .catch(function (error) {
        reject(error);
      });
  });
}

/* Removed canonical thread fetch; we now rely solely on SSE evidence and deltas */

/**
 * Update assistant data with API response
 * @param {Object} param_api_data - Data from the API
 */
function Assistant_UpdateAssistantData(param_api_data) {
  if (param_api_data) {
    // Update name if provided
    if (param_api_data.name && typeof param_api_data.name === 'string') {
      Assistant.assistant.name = param_api_data.name;
    }

    // Update description if provided
    if (param_api_data.description && typeof param_api_data.description === 'string') {
      Assistant.assistant.description = param_api_data.description;
    }

    // Update conversation starters if provided
    if (param_api_data.conversation_starters && Array.isArray(param_api_data.conversation_starters)) {
      Assistant.assistant.conversation_starters = param_api_data.conversation_starters;
    }

    // Keep the public_id that we already set from the hidden input
    // but allow the API to override it if needed
    if (param_api_data.public_id && typeof param_api_data.public_id === 'string') {
      Assistant.assistant.public_id = param_api_data.public_id;
    }

    console.log('Assistant data updated from API:', Assistant.assistant);
  }
}

/**
 * Handle error when sending a message
 * @param {string} param_original_message - The original message that failed to send
 * @param {Error} param_error - The error that occurred
 */
function Assistant_HandleMessageSendError(param_original_message, param_error) {
  var textarea;

  // Remove the user message from the thread since it failed to send
  if (Assistant.thread.messages && Assistant.thread.messages.length > 0) {
    var last_message = Assistant.thread.messages[Assistant.thread.messages.length - 1];
    if (last_message.role === 'user') {
      Assistant.thread.messages.pop();
    }
  }

  // Restore the user's message in the input field
  textarea = Assistant.container.querySelector('#user_chat_message');
  if (textarea) {
    textarea.value = param_original_message;
    Assistant.message_text = param_original_message;
  }

  // Set error state
  Assistant.is_assistant_in_error = true;
  Assistant.error_message = 'Failed to send message: ' + param_error.message + '. Please try again.';

  // Reset submitting state
  Assistant.submitting = false;

  // Update UI to show error and restore input
  Assistant_Render();
  Assistant_SetupEventListeners();
  Assistant_ScrollConversationToBottom();
}

/**
 * Handle streaming errors
 * @param {Object} param_error_data - Error data from the stream
 */
function Assistant_HandleStreamError(param_error_data) {
  // Close the EventSource
  if (Assistant.event_source) {
    Assistant.event_source.close();
    Assistant.event_source = null;
  }

  // Set error state
  Assistant.is_assistant_in_error = true;
  Assistant.error_message = param_error_data.content || 'An error occurred during streaming';

  // Reset other states
  Assistant.is_assistant_thinking = false;
  Assistant.submitting = false;

  // Update UI to show error
  Assistant_RenderLatestResponseToDOM();
  Assistant_UpdateUserControlsState();
  Assistant_ScrollConversationToBottom();

  console.error('Assistant stream error:', param_error_data);
}

/**
 * Finalize the assistant message from accumulated stream content and evidence
 */
function Assistant_FinalizeStreamMessage() {
  if (Assistant.stream_finalized) {
    return;
  }

  // Close the EventSource if open
  if (Assistant.event_source) {
    try {
      Assistant.event_source.close();
    } catch (e) { }
    Assistant.event_source = null;
  }

  // Build final message from accumulated deltas and evidence
  var finalText = Assistant.latest_assistant_response || '';
  var rawEvidence = Array.isArray(Assistant.working_evidence) ? Assistant.working_evidence : [];

  var contentHtml = Assistant.md.render(finalText);
  try {
    var filtered = Assistant_FilterEvidenceWithLandmarks(rawEvidence);
    if (filtered.length > 0) {
      var numbered = Assistant_NumberEvidence(filtered);
      var decorated = Assistant_DecorateWithEvidence(finalText, numbered);
      contentHtml = Assistant.md.render(decorated);
    }
  } catch (e) {
    console.warn('Failed to decorate evidence; rendering plain markdown:', e);
  }

  var assistant_message = {
    role: 'assistant',
    content: finalText,
    content_html: contentHtml,
    evidence: filtered || [],
    timestamp: Date.now()
  };

  if (!Assistant.thread.messages) {
    Assistant.thread.messages = [];
  }
  Assistant.thread.messages.push(assistant_message);

  // Reset streaming temps
  Assistant.latest_assistant_response = '';
  Assistant.working_evidence = [];
  Assistant.stream_finalized = true;

  // Save conversation and render
  Assistant_SaveConversationAfterStream()
    .then(function (saved_thread) {
      console.log('Conversation saved to IndexedDB after stream completion');
      Assistant.current_local_thread_id = saved_thread.id;
      return Assistant_LoadThreads();
    })
    .then(function (threads) {
      if (threads) {
        Assistant.available_threads = threads;
        console.log('Available threads updated after stream completion:', threads.length);
      }
    })
    .catch(function (error) {
      console.warn('Failed to save conversation or reload threads:', error);
    })
    .finally(function () {
      Assistant.submitting = false;
      Assistant.is_assistant_thinking = false;
      Assistant_RenderChatView();
      Assistant_SetupEventListeners();
      Assistant_ScrollConversationToBottom();
      console.log('Assistant response stream completed');
    });
}

/**
 * Complete the streaming process (fallback if evidence was not received)
 */
function Assistant_CompleteStream() {
  if (Assistant.stream_finalized) {
    // Already finalized; just ensure UI states
    Assistant.submitting = false;
    Assistant.is_assistant_thinking = false;
    Assistant_RenderChatView();
    Assistant_SetupEventListeners();
    Assistant_ScrollConversationToBottom();
    return;
  }

  // Finalize with whatever we have (text; evidence may be empty)
  Assistant_FinalizeStreamMessage();
}

/**
 * Clean up EventSource on page unload
 */
function Assistant_CleanupEventSource() {
  if (Assistant.event_source) {
    Assistant.event_source.close();
    Assistant.event_source = null;
  }
  Assistant.submitting = false;
}

/**
 * Render the thread list view
 */
function Assistant_RenderThreadListView() {
  var html = '';

  html += '<div class="ww_skin_assistant_thread_list_container">';
  html += Assistant_RenderThreadListHeader();
  html += Assistant_RenderThreadList();
  html += '</div>';

  Assistant.container.innerHTML = html;
}

/**
 * Render the thread list header with assistant name and new chat button
 * @returns {string} HTML for thread list header
 */
function Assistant_RenderThreadListHeader() {
  var html = '';

  html += '<div class="ww_skin_assistant_thread_list_header">';
  html += '  <div class="ww_skin_assistant_info">';
  html += '    <div class="ww_skin_assistant_avatar">';
  html += '      <i class="fa"></i>';
  html += '    </div>';
  html += '    <h2 class="ww_skin_assistant_name">' + (Assistant.assistant.name || 'Untitled Assistant') + '</h2>';
  html += '  </div>';
  html += '  <button class="ww_skin_assistant_new_chat_button" id="new_chat_button">';
  html += '    <i class="fa"></i> New Chat';
  html += '  </button>';
  html += '</div>';

  return html;
}

/**
 * Render the scrollable thread list
 * @returns {string} HTML for thread list
 */
function Assistant_RenderThreadList() {
  var html, i, thread;

  html = '<div class="ww_skin_assistant_thread_list_scroll">';
  html += '  <p class="ww_skin_assistant_thread_list_title">Recent conversations</p>'

  if (Assistant.available_threads.length === 0) {
    html += '  <div class="ww_skin_assistant_thread_list_empty">';
    html += '    <p>No conversations yet. Start a new chat to begin.</p>';
    html += '  </div>';
  } else {
    for (i = 0;i < Assistant.available_threads.length;i++) {
      thread = Assistant.available_threads[i];
      html += Assistant_RenderThreadItem(thread);
    }
  }

  html += '</div>';

  return html;
}

/**
 * Render an individual thread item
 * @param {Object} param_thread - Thread data
 * @returns {string} HTML for thread item
 */
function Assistant_RenderThreadItem(param_thread) {
  var html, is_deleting, date_text;

  is_deleting = Assistant.deleting_thread_ids.indexOf(param_thread.id) !== -1;
  date_text = Assistant_FormatDate(param_thread.updated_at || param_thread.created_at);

  html = '<div class="ww_skin_assistant_thread_item' + (is_deleting ? ' ww_skin_assistant_thread_item_deleting' : '') + '" ';
  html += 'data-thread-id="' + Assistant_EscapeHtml(param_thread.id) + '">';
  html += '  <div class="ww_skin_assistant_thread_content">';
  html += '    <div class="ww_skin_assistant_thread_title">' + Assistant_EscapeHtml(param_thread.title || 'Untitled Thread') + '</div>';
  html += '    <div class="ww_skin_assistant_thread_actions">';
  html += '      <span class="ww_skin_assistant_thread_date">' + Assistant_EscapeHtml(date_text) + '</span>';
  html += '      <button class="ww_skin_assistant_thread_delete_button" ';
  html += '        data-thread-id="' + Assistant_EscapeHtml(param_thread.id) + '"';
  html += (is_deleting ? ' disabled' : '') + '>';
  html += '        <i class="fa"></i>';
  html += '      </button>';
  html += '    </div>';
  html += '  </div>';
  html += '</div>';

  return html;
}

/**
 * Render the chat view with navigation header
 */
function Assistant_RenderChatView() {
  var html = '';

  html += '<div class="ww_skin_assistant_chat_view_container">';
  html += '<div class="ww_skin_assistant_chat_container">';

  // Add back navigation if we have threads available (now inside the container)
  if (Assistant.available_threads.length > 0) {
    html += Assistant_RenderChatHeader();
  }

  // Add the chat area
  html += '  <div id="assistant_chat_area" class="ww_skin_assistant_chat_area">';
  html += Assistant_RenderMessages();
  html += Assistant_RenderLatestResponse();
  html += '  </div>';

  // Add the input area
  html += '  <div class="ww_skin_assistant_chat_input_area">';
  html += '    <form id="assistant_chat_form" class="ww_skin_assistant_chat_form">';
  html += '      <div class="ww_skin_assistant_chat_input_container ' + (Assistant.submitting ? 'submitting' : '') + '">';
  html += '        <div class="ww_skin_assistant_chat_textarea_wrapper">';
  html += '          <textarea id="user_chat_message" class="ww_skin_assistant_chat_textarea" ';
  html += '            placeholder="Ask ' + (Assistant.assistant.name || 'Untitled Assistant') + ' something..." ';
  html += (Assistant.submitting ? 'disabled' : '') + '></textarea>';
  html += '        </div>';
  html += '        <div class="ww_skin_assistant_chat_actions">';
  html += '          <div class="ww_skin_assistant_chat_actions_left">';
  html += '            <button type="button" id="delete_chat_button" class="ww_skin_assistant_chat_button ww_skin_assistant_ghost_button" ';
  html += '              title="Delete Chat" ' + (Assistant.submitting || !Assistant.current_local_thread_id ? 'disabled' : '') + '>';
  html += '              <i class="fa"></i>';
  html += '            </button>';
  html += '          </div>';
  html += '          <div class="ww_skin_assistant_chat_actions_right">';
  html += '            <button type="submit" id="send_message_button" class="ww_skin_assistant_chat_button ww_skin_assistant_primary_button';
  html += (Assistant.submitting ? ' ww_skin_assistant_chat_button_sending' : '');
  html += '" ' + (Assistant.submitting || Assistant.message_text === '' ? 'disabled' : '') + '>';

  if (Assistant.submitting) {
    html += '<i class="fa spin"></i> Sending';
  } else {
    html += '<i class="fa"></i> Send';
  }

  html += '            </button>';
  html += '          </div>';
  html += '        </div>';
  html += '      </div>';
  html += '    </form>';
  html += '  </div>';
  html += '</div>';
  html += '</div>';

  Assistant.container.innerHTML = html;
}

/**
 * Render the chat header with back arrow
 * @returns {string} HTML for chat header
 */
function Assistant_RenderChatHeader() {
  var html = '';

  html += '<div class="ww_skin_assistant_chat_header">';
  html += '  <button class="ww_skin_assistant_chat_back_button" id="chat_back_button">';
  html += '    <i class="fa"></i>';
  html += '  </button>';
  html += '  <span class="ww_skin_assistant_chat_header_title"></span>';
  html += '</div>';

  return html;
}

/**
 * Set up event listeners for the thread list
 */
function Assistant_SetupThreadListEventListeners() {
  var new_chat_button, thread_items, delete_buttons, i;

  // New chat button
  new_chat_button = Assistant.container.querySelector('#new_chat_button');
  if (new_chat_button) {
    new_chat_button.addEventListener('click', function () {
      Assistant_ShowNewChatView();
    });
  }

  // Thread item clicks (load conversation)
  thread_items = Assistant.container.querySelectorAll('.ww_skin_assistant_thread_item');
  for (i = 0;i < thread_items.length;i++) {
    thread_items[i].addEventListener('click', function (param_event) {
      var thread_id, delete_button_clicked;

      // Don't load if clicking on delete button
      delete_button_clicked = param_event.target.closest('.ww_skin_assistant_thread_delete_button');
      if (delete_button_clicked) {
        return;
      }

      thread_id = param_event.currentTarget.getAttribute('data-thread-id');
      if (thread_id) {
        Assistant_ShowChatView(thread_id);
      }
    });
  }

  // Delete button clicks
  delete_buttons = Assistant.container.querySelectorAll('.ww_skin_assistant_thread_delete_button');
  for (i = 0;i < delete_buttons.length;i++) {
    delete_buttons[i].addEventListener('click', function (param_event) {
      var thread_id;

      param_event.stopPropagation(); // Prevent thread item click
      thread_id = param_event.currentTarget.getAttribute('data-thread-id');
      if (thread_id) {
        Assistant_DeleteThreadItem(thread_id);
      }
    });
  }
}

/**
 * Initialize the UI after data is ready
 */
function Assistant_InitializeUI() {
  // Check if we should show thread list or new chat
  Assistant_ShowThreadListView();
}
