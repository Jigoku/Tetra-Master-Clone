sound = {}
sound.bgm = love.audio.newSource("data/tetramaster.ogg", "stream")
sound.bgm:setLooping(true)
sound.bgm:setVolume(0.5)
sound.bgm:play()
