require 'spec_helper'

describe 'Git Push Deployment' do
  let(:app) { Fabricate :app }
  before do
    # NB: can't stub Peas::TMP_BASE because the module has already been loaded in spec_helper
    stub_const "Peas::APP_REPOS_PATH", "#{TMP_BASE}/repos"
    stub_const "Peas::TMP_TARS", "#{TMP_BASE}/tars"
    FileUtils.rm_rf '/tmp/peas/test/' # Hardcoded for sanity
    # Make sure the git receiver connects to the test switchboard
    stub_const "App::GIT_RECEIVER_PATH", "SWITCHBOARD_PORT=#{SWITCHBOARD_TEST_PORT} #{Peas.root}/bin/git_receiver"
    @non_bare_path = create_non_bare_repo 'sweetpea', app.local_repo_path, false
    @app_local_path = "#{Peas::APP_REPOS_PATH}/#{app.name}"
    expect(App).to receive(:find_by).with(_id: app.id.to_s).and_return(app)
    expect(app).to receive(:deploy).with(an_instance_of(String)) { app.broadcast 'The peas are ripe' }
  end

  it 'should triger a deploy', :with_worker do
    output = Peas.sh "cd #{@non_bare_path} && git push #{@app_local_path} master", 10
    expect(output).to include 'The peas are ripe'
    expect(output).to include '* [new branch]      master -> master'
  end
end
