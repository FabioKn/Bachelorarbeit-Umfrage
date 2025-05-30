mergeInto(LibraryManager.library, {
  SendClick: function (x, y, z) {
    window.parent.postMessage(
      {
        type: 'unity-click',
        x: x,
        y: y,
        z: z
      },
      '*'
    );
  }
});