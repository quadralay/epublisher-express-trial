<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:wwpage="urn:WebWorks-Page-Template-Schema" xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document" xml:lang="en" wwpage:attribute-xml-lang="locale" lang="en" wwpage:attribute-lang="locale" data-highlight-require-whitespace="true" wwpage:attribute-data-highlight-require-whitespace="highlight-require-whitespace">
<head>
    <wwpage:Block wwpage:condition="emit-mark-of-the-web" wwpage:replace="mark-of-the-web" />
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" wwpage:attribute-content="content-type" />
    <meta http-equiv="Content-Style-Type" content="text/css" />
    <meta wwpage:condition="wrapper" name="robots" content="noindex" />
    <meta wwpage:condition="description-exists" name="description" content="description" wwpage:attribute-content="meta-description" />
    <meta wwpage:condition="keywords-exist" name="keywords" content="keywords" wwpage:attribute-content="meta-keywords" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />

    <link wwpage:condition="canonical-url-exists" rel="canonical" href="https://example.com/page.html" wwpage:attribute-href="canonical-url" />

    <meta name="date" content="2025-01-01" wwpage:attribute-content="last-modified-date" />

    <meta wwpage:condition="canonical-url-exists" property="og:url" content="https://example.com/page.html" wwpage:attribute-content="canonical-url" />
    <meta property="og:type" content="article" />
    <meta property="og:title" content="Page Title" wwpage:attribute-content="title" />
    <meta wwpage:condition="description-exists" property="og:description" content="Page description" wwpage:attribute-content="meta-description" />
    <meta wwpage:condition="og-image-exists" property="og:image" content="image.jpg" wwpage:attribute-content="og-image-url" />

    <meta name="twitter:card" content="summary" />
    <meta name="twitter:title" content="Page Title" wwpage:attribute-content="title" />
    <meta wwpage:condition="description-exists" name="twitter:description" content="Page description" wwpage:attribute-content="meta-description" />
    <meta wwpage:condition="og-image-exists" name="twitter:image" content="image.jpg" wwpage:attribute-content="og-image-url" />

    <title wwpage:content="title">Title</title>

    <link wwpage:condition="navigation-previous-exists" rel="Prev" href="previous.html"  wwpage:attribute-href="navigation-previous-link" title="Previous" wwpage:attribute-title="navigation-previous-title" />
    <link wwpage:condition="navigation-next-exists" rel="Next" href="next.html"  wwpage:attribute-href="navigation-next-link" title="Next" wwpage:attribute-title="navigation-next-title" />

    <link rel="StyleSheet" href="css/font-awesome/css/all.min.css" wwpage:attribute-href="relative-to-output-root-with-generation-hash" type="text/css" media="all" />
    <link wwpage:condition="catalog-css" rel="StyleSheet" href="css/catalog.css" wwpage:attribute-href="catalog-css" type="text/css" media="all" />
    <link rel="StyleSheet" href="css/webworks.css" wwpage:attribute-href="copy-from-data-relative-to-output-root-with-generation-hash" type="text/css" media="all" />
    <link rel="StyleSheet" href="css/skin.css" wwpage:attribute-href="copy-from-data-relative-to-output-root-with-generation-hash" type="text/css" media="all" />
    <link rel="StyleSheet" href="css/social.css" wwpage:attribute-href="copy-from-data-relative-to-output-root-with-generation-hash" type="text/css" media="all" />
    <link wwpage:condition="document-css" rel="StyleSheet" href="css/document.css" wwpage:attribute-href="document-css" type="text/css" media="all" />
    <link rel="StyleSheet" href="css/print.css" wwpage:attribute-href="copy-from-data-relative-to-output-root-with-generation-hash" type="text/css" media="print" />

    <noscript>
      <div id='noscript_padding'></div>
    </noscript>
</head>

<body id="" wwpage:attribute-id="body-id" class="" wwpage:attribute-class="body-class" style="visibility: hidden;">
  <input type="hidden" id="page_onload_url" value="" wwpage:attribute-value="page-onload-url" />
  <input type="hidden" id="page_path" value="" wwpage:attribute-value="page-path" />
  <input type="hidden" id="page_landmark_id" value="" wwpage:attribute-value="page-landmark-id" />
    <span id="dropdown_ids" wwpage:condition="page-dropdown-toggle-enabled" wwpage:content="dropdown-ids" style="display:none;"></span>
    <div id="ww_content_container">
      <header id="wwconnect_header" role="banner">
        <nav wwpage:condition="breadcrumbs-exist" wwpage:content="breadcrumbs" class="ww_skin_breadcrumbs" role="navigation" aria-label="Breadcrumb" wwpage:attribute-aria-label="breadcrumb-tooltip">
          Breadcrumbs go here
        </nav>

        <div class="ww_skin_page_toolbar" role="toolbar" aria-label="Page actions" wwpage:attribute-aria-label="page-actions-tooltip">
          <wwexsldoc:NoBreak />

          <div id="dropdown_button_container" class="dropdown_container dropdown_button_container_disabled" wwpage:condition="page-dropdown-toggle-enabled">
            <a id="show_hide_all" class="ww_skin ww_behavior_dropdown_toggle ww_skin_dropdown_toggle" title="Dropdown page toggle" wwpage:attribute-title="navigation-page-dropdown-toggle-title" href="#" aria-label="Toggle all dropdowns" wwpage:attribute-aria-label="toggle-dropdowns-tooltip" aria-expanded="false">
              <i class="far" aria-hidden="true"></i>
            </a>
            <span class="ww_skin_page_toolbar_divider">&#160;</span>
          </div>

          <div id="social_links" wwpage:condition="social-enabled">
            <wwexsldoc:NoBreak />

            <!-- Twitter -->
            <!--         -->
            <a id="social_twitter" wwpage:condition="twitter-enabled" class="ww_social ww_social_twitter" title="Twitter" target="_blank" href="#" aria-label="Share on Twitter" wwpage:attribute-aria-label="share-twitter-tooltip">
              <i class="fab" aria-hidden="true"></i>
            </a>

            <!-- FaceBook Like -->
            <!--               -->
            <a id="social_facebook_like" wwpage:condition="facebook-like-enabled" class="ww_social ww_social_facebook" title="Facebook" target="_blank" href="#" aria-label="Share on Facebook" wwpage:attribute-aria-label="share-facebook-tooltip">
              <i class="fab" aria-hidden="true"></i>
            </a>

            <!-- LinkedIn Share -->
            <!--                -->
            <a id="social_linkedin" wwpage:condition="linkedin-share-enabled" class="ww_social ww_social_linkedin" title="LinkedIn" target="_blank" href="#" aria-label="Share on LinkedIn" wwpage:attribute-aria-label="share-linkedin-tooltip">
              <i class="fab" aria-hidden="true"></i>
            </a>

            <span class="ww_skin_page_toolbar_divider">&#160;</span>
          </div>

          <a wwpage:condition="print-enabled" class="ww_behavior_print ww_skin ww_skin_print" title="Print" wwpage:attribute-title="navigation-print-title" href="#" aria-label="Print this page" wwpage:attribute-aria-label="print-page-tooltip">
            <i class="fa" aria-hidden="true"></i>
          </a>
          <a wwpage:condition="feedback-email" class="ww_behavior_email ww_skin ww_skin_email" title="Email" wwpage:attribute-title="navigation-email-title" href="#" target="_blank" wwpage:attribute-target="wwsetting:external-url-target" aria-label="Send feedback email" wwpage:attribute-aria-label="send-email-tooltip">
            <i class="far" aria-hidden="true"></i>
          </a>
          <a wwpage:condition="pdf-exists pdf-download-exists" class="ww_behavior_pdf ww_skin ww_skin_pdf" title="PDF" wwpage:attribute-title="navigation-pdf-title" href="#" wwpage:attribute-href="pdf-link" target="_blank" wwpage:attribute-target="pdf-target" wwpage:attribute-alt="navigation-pdf-title" download="" wwpage:attribute-download="pdf-download" aria-label="Download PDF" wwpage:attribute-aria-label="download-pdf-tooltip">
            <i class="far" aria-hidden="true"></i>
          </a>
          <a wwpage:condition="pdf-exists pdf-download-not-exists" class="ww_behavior_pdf ww_skin ww_skin_pdf" title="PDF" wwpage:attribute-title="navigation-pdf-title" href="#" wwpage:attribute-href="pdf-link" target="_blank" wwpage:attribute-target="pdf-target" wwpage:attribute-alt="navigation-pdf-title" aria-label="View PDF" wwpage:attribute-aria-label="view-pdf-tooltip">
            <i class="far" aria-hidden="true"></i>
          </a>
          <div wwpage:condition="share-widget-enabled" class="ww_skin_share_container">
            <a id="share_button" class="ww_behavior_share ww_skin ww_skin_share" title="Share" href="#" aria-label="Share this page" aria-expanded="false" aria-haspopup="true">
              <i class="fa" aria-hidden="true"></i>
            </a>
            <div id="share_popup" class="ww_skin_share_popup" role="dialog" aria-label="Share URL">
              <div class="ww_skin_share_popup_row">
                <label class="ww_skin_share_popup_label" for="share_landmark_url">Stable Link</label>
                <div class="ww_skin_share_popup_input_group">
                  <input type="text" id="share_landmark_url" class="ww_skin_share_popup_input" readonly="readonly" value="" />
                  <button type="button" class="ww_skin_share_popup_copy_button" data-clipboard-target="share_landmark_url" aria-label="Copy stable link">Copy</button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- was this helpful button -->
        <!--                         -->
      <div class="ww_skin_was_this_helpful_container" wwpage:condition="page-helpful-buttons-enabled">
          <div class="ww_skin_was_this_helpful_message"  wwpage:content="locales-helpful-message">Was this helpful?</div>
          <div class="ww_skin_was_this_helpful_buttons_container">
            <div id="helpful_thumbs_up" class="ww_skin_was_this_helpful_button" title="Helpful" wwpage:attribute-title="helpful-button" role="button" tabindex="0" aria-label="Yes, this was helpful" wwpage:attribute-aria-label="yes-helpful-tooltip" aria-pressed="false"><i class="far" aria-hidden="true"></i></div>
            <div id="helpful_thumbs_down" class="ww_skin_was_this_helpful_button" title="Unhelpful" wwpage:attribute-title="unhelpful-button" role="button" tabindex="0" aria-label="No, this was not helpful" wwpage:attribute-aria-label="no-helpful-tooltip" aria-pressed="false"><i class="far" aria-hidden="true"></i></div>
          </div>
        </div>
      </header>

      <main id="page_content_container" tabindex="-1" style="" wwpage:attribute-style="body-style">
        <div id="page_content" wwpage:content="content">
          Page content.
        </div>
        <div id="page_dates">
          <div class="ww_skin_page_publish_date" wwpage:condition="display-page-publish-date" wwpage:content="publish-date">published date</div>
          <div class="ww_skin_document_last_modified_date" wwpage:condition="display-document-last-modified-date" wwpage:content="document-last-modified-date">last modified date</div>
        </div>
        <!-- Related Topics -->
        <!--                -->
        <div wwpage:replace="RelatedTopics">Related Topics</div>
        <footer>
          <!-- Disqus -->
          <!--        -->
          <div id="disqus_developer_enabled" wwpage:condition="disqus-developer-enabled" style="display:none;"></div>
          <div id="disqus_thread" wwpage:condition="disqus-enabled"></div>

          <!-- Google Translation -->
          <!--                    -->
          <div class="ww_skin_page_globalization" wwpage:condition="google-translation-enabled">
            <div id="google_translate_element">&#160;</div>
          </div>

          <br />
        </footer>
      </main>
    </div>
    <input type="hidden" id="preserve_unknown_file_links" value="false" wwpage:attribute-value="preserve-unknown-file-links" />
    <noscript>
      <div id='noscript_warning' wwpage:content="locales-no-javascript-message">This site works best with JavaScript enabled</div>
    </noscript>

  <script type="text/javascript" src="scripts/common.js" wwpage:attribute-src="copy-relative-to-output-root-with-generation-hash"></script>
  <script type="text/javascript" src="scripts/page.js" wwpage:attribute-src="copy-relative-to-output-root-with-generation-hash"></script>
  <script type="text/javascript" src="scripts/search-client.js" wwpage:attribute-src="copy-relative-to-output-root-with-generation-hash"></script>
  <script type="text/javascript" src="scripts/unidata.js" wwpage:attribute-src="copy-relative-to-output-root-with-generation-hash"></script>
  <script type="text/javascript" src="scripts/unibreak.js" wwpage:attribute-src="copy-relative-to-output-root-with-generation-hash"></script>
</body>
</html>
