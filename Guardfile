guard :jasmine do
  watch(%r{tests/.+_spec\.(js\.coffee|js|coffee)$})
  watch(%r{source/.\.(js\.coffee|js|coffee)$})
  watch(%r{source/(.+?)\.(js\.coffee|js|coffee)(?:\.\w+)*$}) { |m| "tests/#{ m[1] }_spec.#{ m[2] }" }
end

guard :coffeescript, :input => 'source', :output => 'compiled'