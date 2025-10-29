require 'rails_helper'

RSpec.describe ConflictCollector, type: :service do
  let(:prospective_matter) { build(:legal_matter) }
  let(:attorney) { build(:attorney) }
  let(:former_matter_1) { build(:legal_matter, matter_number: "2024-001", assigned_attorney: attorney) }
  let(:former_matter_2) { build(:legal_matter, matter_number: "2024-002", assigned_attorney: attorney) }
  let(:detector_double) { instance_double(ConflictDetectors::ConcurrentConflictDetector) }

  describe '#search' do
    let(:mock_attorney) { build(:attorney, name: "Test Attorney") }

    before do
      allow(LegalMatter).to receive(:all).and_return([ former_matter_1, former_matter_2 ])
      allow(Attorney).to receive(:find_by_name).with("Test Attorney").and_return(mock_attorney)
    end

    it 'returns an array of arrays (one per detector)' do
      collector = described_class.new(prospective_matter)
      results = collector.search

      expect(results.length).to eq(collector.detectors.length)
    end

    context 'when conflicts are found' do
      let(:conflict_1) { { type: :concurrent_conflict, former_matter: former_matter_1 } }
      let(:conflict_2) { { type: :concurrent_conflict, former_matter: former_matter_2 } }

      before do
        allow(detector_double).to receive(:detect).and_return(conflict_1, conflict_2)
        allow(ConflictDetectors::ConcurrentConflictDetector).to receive(:new).and_return(detector_double)
      end

      it 'returns conflicts from all detectors' do
        collector = described_class.new(prospective_matter)
        results = collector.search

        expect(results.length).to eq(collector.detectors.length)
      end
    end
  end
end
