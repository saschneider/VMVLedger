#
# URL validator file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class UrlValidator < ActiveModel::EachValidator

  #
  # Validates that a string field is a URL.
  #
  # @param record The owning record.
  # @param attribute The attribute to validate.
  # @param value The value to validate.
  #
  def validate_each(record, attribute, value)
    begin
      uri = URI.parse(value)
      raise RecordInvalid unless uri.kind_of?(URI::HTTP)
    rescue => _e
      record.errors[attribute] << (options[:message] || I18n.t('activerecord.validators.not_a_url'))
    end
  end

end