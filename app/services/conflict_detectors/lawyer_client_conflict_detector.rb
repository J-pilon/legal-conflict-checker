module ConflictDetectors
  class LawyerClientConflictDetector < ConflictDetector
    def self.detect(former_matter, prospective_matter)
      instance = new(former_matter, prospective_matter)
      instance.detect
    end

    def detect
      return nil if former_matter.matter_number == prospective_matter.matter_number

      return nil if prospective_matter.assigned_attorney.nil?

      conflict_detected = prospective_matter.assigned_attorney.business_interests.any? do |interest|
        interest.downcase == former_matter.client_name.downcase
      end

      conflict_detected ? {
        type: :lawyer_client_conflict,
        former_matter: former_matter,
        reason: "Assigned attorney has business interest conflict"
      } : nil
    end
  end
end
