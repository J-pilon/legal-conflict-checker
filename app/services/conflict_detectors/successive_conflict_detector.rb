module ConflictDetectors
  class SuccessiveConflictDetector < ConflictDetector
    def self.detect(former_matter, prospective_matter)
      instance = new(former_matter, prospective_matter)
      instance.detect
    end

    def detect
      return false if former_matter.matter_number == prospective_matter.matter_number

      description_keywords = former_matter.description.split(" ")

       matched_keywords = description_keywords.filter_map do |keyword|
        formatted_prospective_matter = prospective_matter.description.downcase
        formatted_prospective_matter.include?(keyword.downcase) ? keyword : nil
      end

      return nil unless matched_keywords.any?

      percentage_of_matched_keywords = matched_keywords.length / description_keywords.length.to_f
      conflict_detected = percentage_of_matched_keywords >= 0.4

      conflict_detected ? {
        type: :successive_conflict,
        former_matter: former_matter,
        reason: "Former client in the same or a related matter"
      } : nil
    end
  end
end
