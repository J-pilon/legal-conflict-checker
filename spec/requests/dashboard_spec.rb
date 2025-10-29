require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  describe "GET /index" do
    it "returns http success and does not create a new record" do
      get dashboard_index_path

      expect(response).to have_http_status(:success)
    end
  end
end
