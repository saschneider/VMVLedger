#
# Duration validator file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class DurationValidator < ActiveModel::EachValidator

  #
  # Validates that a string field is a duration stored in ISO8601 format.
  #
  # @param record The owning record.
  # @param attribute The attribute to validate.
  # @param value The value to validate.
  #
  def validate_each(record, attribute, value)
    begin
      ActiveSupport::Duration.parse(value)
    rescue => _e
      record.errors[attribute] << (options[:message] || I18n.t('activerecord.validators.not_a_duration'))
    end
  end

end