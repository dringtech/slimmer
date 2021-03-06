# 8.3.0

* Add support for 403 error page.

# 8.2.1

* Update rendering app meta tag to use GOVUK_APP_NAME env variable if available

# 8.2.0

* Add meta tag for currently running application

# 8.1.0

* Add remove_search header which strips out the search box in the header.

# 8.0.0

* Switch from JS custom variables to HTML meta tags

  Slimmer now appends page metadata as meta tags instead of setting Google
  custom variables within a script tag. The Google-specific implementation
  details have been removed.

  Any apps that need to report analytics events will require additional
  Javascript that reads the meta tags and sends the relevant data to the
  analytics platform. The current best practice for doing this is using
  the GOV.UK Analytics API - you can find the [code, examples and documentation
  in `govuk_frontend_toolkit`](https://github.com/alphagov/govuk_frontend_toolkit/blob/master/docs/analytics.md).

* Remove Proposition header, since this information wasn't being used

# 7.0.0

* Remove AlphaLabelInserter, BetaNoticeInserter, BetaLabelInserter. These are
  now better handled by govuk_components
* Remove LogoClassInserter. BusinessLink and DirectGov branding is being
  removed so we don't need to insert their logos
* Loosen Nokogiri dependency. Rails 4.2 needs Nokogiri 1.6.0 and above.

# 6.0.0

* Change ComponentResolver to use a bespoke tag - `test-govuk-component` - when
  running in a test, rather than `script`. Use `data-template` rather than
  `class` to identify which template was used.
* Fix bug where Slimmer::TestHelpers::SharedTemplates#shared_component_selector
  returned the wrong selector.

# 5.1.0

* `ComponentResolver#test_body` returns a JSON blob of the components keys and values instead of just the values.

* Add an I18n backend to load translations over the network from static

# 5.0.1

* Fix MetaViewportRemover to not raise an exception if there is no meta
  viewport tag. Issue became apparent in 4.3.1.

# 5.0.0

This release contains breaking changes.

* The report-a-problem form is now zero-configuration; it's no longer necessary
  to add a `div class="report-a-problem"` or extra styling to the app. Slimmer
  appends the form to the `wrapper` div by default (the default CSS selector for
  the wrapper div is `#wrapper`, but this id can be overwritten by defining
  `config.slimmer.wrapper_id` in the app's `application.rb`).

* The report-a-problem form is now opt-out; it's added by default, but can be
  skipped by setting the `Slimmer::Headers::REPORT_A_PROBLEM_FORM` header value
  to `false`.

* The steps for upgrading an app that already has report-a-problem are:

  1. Remove all `div class="report-a-problem"` from the app
  2. Remove all CSS relating to `report-a-problem` or `report-a-problem-toggle`
  3. Set `Slimmer::Headers::REPORT_A_PROBLEM_FORM` to `false` for any controllers
  or actions where you don't want the form to appear.

# 4.3.1

* When running tests, don't hide exceptions in the processors. Fix a bug in the
  Search-Parameters processor's handling of missing headers revealed by this.

# 4.3.0

* Add a Search-Parameters header, to allow apps to add extra parameters to
  search requests made from the page.

# 4.2.2

* Remove unused include

# 4.2.1

* Use a shared cache between shared templates and skin templates so that they
  all update together

# 4.2.0

* Add ability to load shared erb templates over the network

# 4.1.1

* Assets are loaded from production instead of preview environment in test mode

# 4.1.0

* Add ALPHA_LABEL functionality

# 4.0.1

* Improve exception reporting by including rack_env

# 4.0.0

* Remove search-index header as there are no longer tabs on search

# 3.29.0

* Send processor exceptions to errbit via Airbrake gem if present

# 3.28.1

* Added nil check for multivalue custom vars in google analytics configurator

# 3.28.0

* Report multiple need ids to Google analytics and Performance tracking
* Removed unused need_id header

# 3.27.0

* Added BETA_LABEL header and deprecated BETA_NOTICE header.

# 3.26.0

* Added X-Slimmer-World-Location header, value of which will be passed onto Google Analytics.

# 3.25.0

* Pass on GOVUK-Request-Id HTTP header when fetching templates
* Use correct asset host in test templates
* Remove a redundant ERB pass over fetched templates

# 3.24.0

* Removed CampaignNotificationInserter.  The homepage no longer needs these inserted.

# 3.1.0

* 'Breadcrumb' trail is now populated from the artefact data. It adds the section and subsection.

# 3.0.0

Backwards-incompatible changes:
* Artefact is expected to follow the format emitted by the Content API

# 2.0.0

Backwards-incompatible changes:

* Artefact has to be explicitly passed to slimmer.
* RelatedItemsInserter uses passed artefact instead of calling out to panopticon.
* Slimmer now strips all X-Slimmer-* HTTP headers from the final response.

Other changes

* new LogoClassInserter module - adds classes to the `#wrapper` element to control the appearence of the directgov and businesslink logos
* Rounded Corners!!! (it is 2.0 after all)

# 0.9.0

* Moved templates into slimmer rather than using separate static project
* Added railtie so that slimmer can be dropped into a rails app without configuration
* Began to write *gasp* tests!
