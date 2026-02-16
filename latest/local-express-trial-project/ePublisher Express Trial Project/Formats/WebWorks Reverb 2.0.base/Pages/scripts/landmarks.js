var Landmarks = (function () {
  function packKey(file_index, anchor_index) { return file_index + '|' + anchor_index; }
  function splitPath(path) {
    var i = path.indexOf('#');
    return (i < 0) ? { file: path, anchor: "" } : { file: path.slice(0, i), anchor: path.slice(i + 1) };
  }

  // Null-prototype dict helpers
  function dict() { return Object.create(null); }
  function dget(d, k) { return (k in d) ? d[k] : undefined; }
  function dset(d, k, v) { d[k] = v; }
  function dhas(d, k) { return (k in d); }

  var Landmarks = {
    data: {
      // intern pools
      f: [],                 // files
      a: [],                 // anchors
      fileIndex: dict(),     // file string -> fi
      anchorIndex: dict(),   // anchor string -> ai

      // minimal indexes
      ids: dict(),           // id -> [fi, ai]
      pairToId: dict(),      // "fi|ai" -> id
    },

    loaded: false,
    loading: false,
    expected: 0,
    loaded_count: 0,

    GetPathById: function (id) {
      var pair = dget(Landmarks.data.ids, id);
      if (!pair) return null;
      var file = Landmarks.data.f[pair[0]];
      var anchor = Landmarks.data.a[pair[1]];
      return anchor ? (file + '#' + anchor) : file;
    },

    GetIdByPath: function (path) {
      var parts = splitPath(path);
      var fileIndex = dget(Landmarks.data.fileIndex, parts.file);
      if (fileIndex === undefined) return null;
      var anchorIndex = dget(Landmarks.data.anchorIndex, parts.anchor || "");
      if (anchorIndex === undefined) return null;
      var id = dget(Landmarks.data.pairToId, packKey(fileIndex, anchorIndex));
      return id || null;
    },

    GetIdByParts: function (file, anchor) {
      var fileIndex = dget(Landmarks.data.fileIndex, file);
      if (fileIndex === undefined) return null;
      var anchorIndex = dget(Landmarks.data.anchorIndex, anchor || "");
      if (anchorIndex === undefined) return null;
      var id = dget(Landmarks.data.pairToId, packKey(fileIndex, anchorIndex));
      return id || null;
    },

    ExtractLandmark: function (param_hash) {
      var m = /^#\/([A-Za-z0-9]{16})(.*)$/.exec(param_hash || '');
      if (m) {
        return m[1];
      }
      return null;
    },

    Advance: function (chunk) {
      var D = Landmarks.data;

      // merge files (local -> global idx)
      var fiMap = [];
      if (chunk && chunk.f) {
        for (var i = 0;i < chunk.f.length;i++) {
          var file = chunk.f[i];
          var gfi = dget(D.fileIndex, file);
          if (gfi === undefined) {
            gfi = D.f.length;
            D.f.push(file);
            dset(D.fileIndex, file, gfi);
          }
          fiMap[i] = gfi;
        }
      }

      // merge anchors (local -> global idx)
      var aiMap = [];
      if (chunk && chunk.a) {
        for (var j = 0;j < chunk.a.length;j++) {
          var anch = chunk.a[j];
          var gai = dget(D.anchorIndex, anch);
          if (gai === undefined) {
            gai = D.a.length;
            D.a.push(anch);
            dset(D.anchorIndex, anch, gai);
          }
          aiMap[j] = gai;
        }
      }

      // merge entries
      var e = (chunk && chunk.e) ? chunk.e : [];
      for (var k = 0;k < e.length;k++) {
        var row = e[k];
        var fi = fiMap[row[0]];
        var ai = aiMap[row[1]];
        var id = row[2];
        if (fi === undefined || ai === undefined || !id) continue;

        dset(D.ids, id, [fi, ai]);                // id -> [fi, ai]
        dset(D.pairToId, packKey(fi, ai), id);    // (fi,ai) -> id
      }

      // completion bookkeeping (unchanged)
      if (typeof Landmarks.loaded_count !== 'number') { Landmarks.loaded_count = 0; }
      if (typeof Landmarks.expected !== 'number') { Landmarks.expected = 0; }

      Landmarks.loaded_count += 1;

      if (Landmarks.loaded_count >= Landmarks.expected) {
        Landmarks.loaded = true;
        Landmarks.loading = false;
      }
    },

    Load: function () {
      // Ensure parcels are fully loaded first
      //
      if (!Parcels.loaded_all) {
        Connect_Window.setTimeout(Landmarks.Load, 100);
        return;
      }

      var urls = Parcels.landmarks.slice(0);

      Landmarks.expected = urls.length;
      Landmarks.loaded_count = 0;

      if (Landmarks.expected === 0) {
        Landmarks.loaded = true;
        Landmarks.loading = false;
        return;
      }

      for (var i = 0;i < urls.length;i++) {
        (function (data_entry) {
          // Always inject script so it executes and calls Landmarks.control.advance(...)
          // This avoids issues with manual parsing of JS files which may contain unexpected whitespace/formatting
          var script_element = Connect_Window.document.createElement('script');
          script_element.src = data_entry;
          script_element.onerror = function () {
            console.error('Failed to load landmark:', data_entry);

            // Avoid deadlock on errors
            if (typeof Landmarks.loaded_count !== 'number') { Landmarks.loaded_count = 0; }
            if (typeof Landmarks.expected !== 'number') { Landmarks.expected = 0; }

            Landmarks.loaded_count += 1;

            if (Landmarks.loaded_count >= Landmarks.expected) {
              Landmarks.loaded = true;
              Landmarks.loading = false;
            }
          };
          Connect_Window.document.body.appendChild(script_element);
        })(urls[i]);
      }
    }
  };

  return Landmarks;
})();
