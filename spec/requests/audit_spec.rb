require 'rails_helper'

RSpec.describe "Audit", type: :request do
  describe "PUT /update" do
    it "returns http ok" do
      matter_number = LegalMatter.all.first.matter_number

      put "/audit/update", params: {
        audit: {
          matter_number: matter_number,
          action: "Cleared"
        }
      }

      expect(response).to have_http_status(:ok)
    end

    it "returns not_found when matter is missing" do
      put "/audit/update", params: {
        audit: {
          matter_number: "NON-EXISTENT-MATTER",
          action: "Cleared"
        }
      }

      expect(response).to have_http_status(:not_found)
    end

    it "returns internal_server_error on unexpected error" do
      matter_number = LegalMatter.all.first.matter_number
      allow(YAML).to receive(:load_file).and_raise(StandardError.new("Boom"))

      put "/audit/update", params: {
        audit: {
          matter_number: matter_number,
          action: "Cleared"
        }
      }

      expect(response).to have_http_status(:internal_server_error)
    end
  end
end
