Gem::Specification.new do |s|
  s.name        = 'polidea-artifacts'
  s.version     = '0.1.0'

  s.description = 'Mobile artifacts deploy tool'
  s.summary     = s.description

  s.homepage    = 'https://github.com/Polidea/polidea-artifacts'
  s.authors     = ['blazej.marcinkiewicz@polidea.com', 'michal.tajchert@polidea.com', 'ruby_apk - SecureBrain, github.com/securebrain/ruby_apk']
  s.email       = 'blazej.marcinkiewicz@polidea.com'

  s.add_dependency 'aws-sdk',            '~> 1.51.0'
  s.add_dependency 'rubyzip',            '~> 1.1.6'
  s.add_dependency 'CFPropertyList',     '~> 2.2.8'
  s.add_dependency 'dropbox-sdk',        '~> 1.6.4'
  s.add_dependency 'rqrcode_png',        '~> 0.1.2'
  s.add_dependency 'shorturl',           '~> 1.0.0'

  s.add_development_dependency 'rspec'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(/^bin/).map{|f| File.basename(f) }
  s.test_files    = s.files.grep(/^spec/)
  s.require_paths = ['lib']

end
