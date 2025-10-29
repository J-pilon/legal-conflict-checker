require 'rails_helper'

RSpec.describe LegalMatter, type: :model do
  describe '.all' do
    let(:mock_data) do
      {
        "legal_matters" => [
          {
            "matter_number" => "2024-001",
            "title" => "Test Matter 1",
            "client_name" => "Client A",
            "client_type" => "Corporation",
            "practice_area" => "Corporate Law",
            "matter_type" => "Contract",
            "status" => "Active",
            "opened_date" => "2024-01-01",
            "closed_date" => nil,
            "adverse_parties" => [],
            "related_parties" => [],
            "assigned_attorney" => "Attorney A",
            "description" => "Test description"
          },
          {
            "matter_number" => "2024-002",
            "title" => "Test Matter 2",
            "client_name" => "Client B",
            "client_type" => "Individual",
            "practice_area" => "Family Law",
            "matter_type" => "Divorce",
            "status" => "Closed",
            "opened_date" => "2024-01-15",
            "closed_date" => "2024-03-01",
            "adverse_parties" => ["Adverse Party"],
            "related_parties" => ["Related Party"],
            "assigned_attorney" => "Attorney B",
            "description" => "Another description"
          }
        ]
      }
    end

    before do
      allow(YAML).to receive(:load_file).and_return(mock_data)
      allow(Rails.root).to receive(:join).with("legal_matter_mocks.yml").and_return("legal_matter_mocks.yml")
    end

    it 'returns an array of LegalMatter objects' do
      legal_matters = LegalMatter.all

      expect(legal_matters).to be_an(Array)
      expect(legal_matters.length).to eq(2)
      expect(legal_matters.first).to be_an(LegalMatter)
    end

    it 'initializes LegalMatter objects with correct attributes' do
      legal_matters = LegalMatter.all

      expect(legal_matters.first.matter_number).to eq("2024-001")
      expect(legal_matters.first.client_name).to eq("Client A")
      expect(legal_matters.first.status).to eq("Active")
      expect(legal_matters.first.closed_date).to be_nil

      expect(legal_matters.last.matter_number).to eq("2024-002")
      expect(legal_matters.last.status).to eq("Closed")
      expect(legal_matters.last.closed_date).to eq("2024-03-01")
    end
  end

  describe '#initialize' do
    let(:matter_data) do
      {
        "matter_number" => "2024-999",
        "title" => "Test Matter",
        "client_name" => "Test Client",
        "client_type" => "LLC",
        "practice_area" => "Tax Law",
        "matter_type" => "Tax Audit",
        "status" => "Active",
        "opened_date" => "2024-01-01",
        "closed_date" => nil,
        "adverse_parties" => ["Adverse Party A"],
        "related_parties" => ["Related Party B"],
        "assigned_attorney" => "Test Attorney",
        "description" => "Test description"
      }
    end

    it 'initializes a LegalMatter with correct attributes' do
      matter = LegalMatter.new(matter_data)

      expect(matter.matter_number).to eq("2024-999")
      expect(matter.title).to eq("Test Matter")
      expect(matter.client_name).to eq("Test Client")
      expect(matter.client_type).to eq("LLC")
      expect(matter.practice_area).to eq("Tax Law")
      expect(matter.matter_type).to eq("Tax Audit")
      expect(matter.status).to eq("Active")
      expect(matter.opened_date).to eq("2024-01-01")
      expect(matter.closed_date).to be_nil
      expect(matter.adverse_parties).to eq(["Adverse Party A"])
      expect(matter.related_parties).to eq(["Related Party B"])
      expect(matter.description).to eq("Test description")
    end
  end

  describe '#assigned_attorney' do
    let(:attorney) { build(:attorney, name: "Test Attorney Name") }
    let(:matter_data) do
      {
        "matter_number" => "2024-999",
        "title" => "Test Matter",
        "client_name" => "Test Client",
        "client_type" => "Corporation",
        "practice_area" => "Corporate Law",
        "matter_type" => "Contract",
        "status" => "Active",
        "opened_date" => "2024-01-01",
        "closed_date" => nil,
        "adverse_parties" => [],
        "related_parties" => [],
        "assigned_attorney" => "Test Attorney Name",
        "description" => "Test description"
      }
    end

    before do
      allow(Attorney).to receive(:find_by_name).with("Test Attorney Name").and_return(attorney)
    end

    it 'returns the assigned attorney object' do
      matter = LegalMatter.new(matter_data)

      expect(matter.assigned_attorney).to eq(attorney)
      expect(matter.assigned_attorney).to be_an(Attorney)
    end

    it 'returns nil when attorney is not found' do
      allow(Attorney).to receive(:find_by_name).and_return(nil)
      matter = LegalMatter.new(matter_data)

      expect(matter.assigned_attorney).to be_nil
    end
  end

  describe 'with FactoryBot' do
    it 'creates a valid legal matter' do
      matter = build(:legal_matter)

      expect(matter.matter_number).to be_present
      expect(matter.title).to be_present
      expect(matter.client_name).to be_present
      expect(matter.status).to eq("Active")
    end

    it 'creates an active matter' do
      matter = build(:legal_matter, :active)

      expect(matter.status).to eq("Active")
      expect(matter.closed_date).to be_nil
    end

    it 'creates a closed matter' do
      matter = build(:legal_matter, :closed)

      expect(matter.status).to eq("Closed")
      expect(matter.closed_date).to eq("2024-03-01")
    end

    it 'creates a matter with related parties' do
      matter = build(:legal_matter, :with_related_party)

      expect(matter.related_parties).to include("Related Party (Role)")
    end

    it 'creates a matter with adverse parties' do
      matter = build(:legal_matter, :with_adverse_party)

      expect(matter.adverse_parties).to include("Adverse Party")
    end
  end
end
