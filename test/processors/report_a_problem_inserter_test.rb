require_relative '../test_helper'

class ReportAProblemInserterTest < MiniTest::Test

  def setup
    super
    @report_a_problem_template = File.read( File.dirname(__FILE__) + "/../fixtures/report_a_problem.raw.html.erb", :encoding => 'utf-8')
    @skin = stub("Skin", :template => nil)
  end

  def test_should_add_report_a_problem_form_using_the_template_from_static
    @skin.expects(:template).with('report_a_problem.raw').returns(@report_a_problem_template)

    headers = { Slimmer::Headers::APPLICATION_NAME_HEADER => 'government' }
    Slimmer::Processors::ReportAProblemInserter.new(
      @skin,
      "http://www.example.com/somewhere?foo=bar",
      headers,
      "wrapper"
    ).filter(:any_source, template)

    assert_in template, "#wrapper div.report-a-problem-container"
    assert_in template, "div.report-a-problem-container form input[name=url][value='http://www.example.com/somewhere?foo=bar']"
    assert_in template, "div.report-a-problem-container form input[name=source][value='government']"
  end

  def test_should_add_page_owner_if_provided_in_headers
    @skin.expects(:template).with('report_a_problem.raw').returns(@report_a_problem_template)
    headers = { Slimmer::Headers::PAGE_OWNER_HEADER => 'hmrc' }
    Slimmer::Processors::ReportAProblemInserter.new(
      @skin,
      "http://www.example.com/somewhere",
      headers,
      "wrapper"
    ).filter(:any_source, template)

    assert_in template, "#wrapper div.report-a-problem-container"
    assert_in template, "div.report-a-problem-container form input[name=page_owner][value='hmrc']"
  end

  def test_should_not_add_report_a_problem_form_if_wrapper_element_missing
    template = as_nokogiri %{
      <html>
        <body class="mainstream">
        </body>
      </html>
    }

    @skin.expects(:template).never # Shouldn't fetch template when not inserting block

    Slimmer::Processors::ReportAProblemInserter.new(@skin, "", {}, "wrapper").filter(:any_source, template)
    assert_not_in template, "div.report-a-problem-container"
  end

  def test_should_not_add_report_a_problem_form_if_app_opts_out_in_header
    @skin.expects(:template).never
    headers = { Slimmer::Headers::REPORT_A_PROBLEM_FORM => 'false' }
    Slimmer::Processors::ReportAProblemInserter.new(@skin, "", headers, "wrapper").filter(:any_source, template)
    assert_not_in template, "div.report-a-problem-container"
  end

  private

  def template
    @template ||= as_nokogiri %{
      <html>
        <body">
          <div id="wrapper">
            <div id="content"></div>
          </div>
        </body>
      </html>
    }
  end
end
