require_relative '../test_helper'

class ClientReplyValidationTest < Test::Unit::TestCase
  VALIDATION_JSON_PATH = File.join(
    File.expand_path('../../..', __FILE__),
    'lib', 'fhir_client', 'fhir_api_validation.json'
  ).freeze

  def validation_rules
    @validation_rules ||= JSON.parse(File.read(VALIDATION_JSON_PATH))
  end

  def form_body_regex
    rule = validation_rules.find { |r| r.dig('request', 'body').is_a?(Hash) && r.dig('request', 'body', 'regex') }
    Regexp.new(rule['request']['body']['regex'])
  end

  def test_fhir_api_validation_json_parses_without_error
    assert_nothing_raised(JSON::ParserError) { JSON.parse(File.read(VALIDATION_JSON_PATH)) }
  end

  def test_operation_form_body_regex_matches_empty_body
    assert_match form_body_regex, ''
  end

  def test_operation_form_body_regex_matches_single_param
    assert_match form_body_regex, 'foo=bar'
  end

  def test_operation_form_body_regex_matches_multiple_params
    assert_match form_body_regex, 'foo=bar&baz=qux'
  end

  def test_operation_form_body_regex_matches_param_without_value
    assert_match form_body_regex, 'param1=value1&param2'
  end

  def test_operation_form_body_regex_treats_backslash_w_as_word_char_class
    # If \\\\w was used in the JSON instead of \\w, the compiled regex would
    # treat [\\w] as matching a literal backslash or 'w', not word characters.
    # Verify \w acts as a word-character class by matching digits and underscores.
    assert_match form_body_regex, '_count=10'
    assert_match form_body_regex, 'param1=value1'
  end
end
