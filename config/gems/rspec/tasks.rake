namespace :gem do

  task :rspec do

    exec 'bin/rspec --options ./config/gems/rspec/.rspec'

  end

end
