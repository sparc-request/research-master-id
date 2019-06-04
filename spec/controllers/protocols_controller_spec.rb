require 'rails_helper'

describe ProtocolsController, type: :controller do
  it 'should have a signed in user' do
    create(:protocol, primary_pi: create(:user, name: 'pi'))
    create(:protocol, primary_pi: create(:user, name: 'pi'))

    get :index

    expect(response).to have_http_status 302
  end

  it 'should only allow admins to view' do
    user = create(:user)
    sign_in user
    create(:protocol, primary_pi: create(:user, name: 'pi'))
    create(:protocol, primary_pi: create(:user, name: 'pi'))

    get :index

    expect(response).to have_http_status 302
  end

  it 'should only allow admins to view' do
    user = create(:user, admin: true)
    sign_in user
    create(:protocol, primary_pi: create(:user, name: 'pi'))
    create(:protocol, primary_pi: create(:user, name: 'pi'))

    get :index

    expect(response).to have_http_status 200
  end
end

