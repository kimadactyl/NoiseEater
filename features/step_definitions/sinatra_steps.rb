Given(/^I am on the homepage$/) do
  visit "/"
end

Then(/^I should see "(.*?)" in the selector "(.*?)"$/) do |text, selector|
  expect(page).to have_selector(selector, text)
end

Given(/^I have provided a valid audio file or URL$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^The audio file is below the maximum file size$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I have entered a valid email address$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I have agreed to the terms and conditions$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I have selected at least one test \{wind noise, handling noise, distortion\}$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I am not currently waiting for another audio file report$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should be shown a confirmation$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^told to wait for an email containing a link to the audio file report$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^given an estimate of how long it will take to get the audio file report$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I have provided an invalid audio file or URL$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should be told the format is incorrect$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I have provided an invalid email address$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should be promoted to correct my email address$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^the user is currently waiting for another audio file report$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see an error message explaining the status of the project$/) do
  pending # express the regexp above with the code you wish you had
end
