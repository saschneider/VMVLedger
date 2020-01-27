#
# Attached validator file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class AttachedValidator < ActiveModel::EachValidator

  #
  # Called to perform the required validation on a model and its attribute.
  #
  # @param record The model to validate.
  # @param attribute The attribute of the model to validate.
  # @param value The value of the attribute.
  #
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :attached, options) unless value.attached?
  end
end
