#
# Font Awesome helper tests.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

require 'test_helper'

class FontAwesomeHelperTest < ActionView::TestCase

  test 'font awesome with default options' do
    assert_equal '<i class="fas fa-pencil fa-lg " aria-hidden="true"></i>', fa_icon('pencil lg')
  end

  test 'font awesome with options' do
    assert_equal '<i title="hello" class="fas fa-pencil fa-lg testing" aria-hidden="false"></i>', fa_icon('pencil lg', title: 'hello', 'aria-hidden' => false, class: 'testing')
    assert_equal '<i title="hello" class="fab fa-pencil fa-lg testing" aria-hidden="false"></i>', fa_icon('pencil lg', title: 'hello', 'aria-hidden' => false, icon_class: 'fab', class: 'testing')
  end

end