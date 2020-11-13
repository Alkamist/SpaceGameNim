import gamerenderer

proc main =
  var renderer = initGameRenderer(
    windowTitle = "Game Window",
    windowWidth = 800,
    windowHeight = 600,
    displayFps = 300.0,
    physicsFps = 60.0,
  )

  renderer.run()

main()