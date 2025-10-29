require 'rails_helper'

RSpec.describe "NewIntakes", type: :request do
  describe "POST /create" do
    it "returns http created and creates a new record" do
      initial_count = LegalMatter.all.length

      post "/new_intake/create", params: {
        new_intake: {
          matter_number: "2024-TEST-001",
          title: "Test Matter",
          client_name: "Test Client",
          client_type: "Individual",
          practice_area: "Test Area",
          matter_type: "Test Type",
          status: "Active",
          opened_date: "2024-01-01",
          assigned_attorney: "Test Attorney",
          description: "Test description",
          adverse_parties: [],
          related_parties: []
        }
      }

      expect(response).to have_http_status(:created)
      expect(LegalMatter.all.length).to eq(initial_count + 1)
    end

    it "returns unprocessable_entity on error and does not create a record" do
      initial_count = LegalMatter.all.length

      post "/new_intake/create", params: {}

      expect(response).to have_http_status(:unprocessable_entity)
      expect(LegalMatter.all.length).to eq(initial_count)
    end
  end
end
