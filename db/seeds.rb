@user = User.create(email: 'example123@musc.edu', password: 'password',
                    password_confirmation: 'password')
10.times do
  ResearchMaster.create(pi_name: Faker::Hipster.word, department: Faker::Company.name,
                        long_title: Faker::Beer.name, short_title: Faker::Superhero.name,
                        funding_source: Faker::StarWars.character, user: @user)
end
