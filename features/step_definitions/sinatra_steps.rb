Given(/^I am on the homepage$/) do
  visit "/"
end

Then(/^I should see "(.*?)"$/) do |text|
  expect(page).to have_content text
end

Given(/^I have selected "(.*?)"$/) do |filename|
  page.attach_file "audio", filename
end

Given(/^I have entered a valid email address$/) do
  page.fill_in 'Email:', :with => 'kim@alliscalm.net'
end

Given(/^I have agreed to the terms and conditions$/) do
  page.check "I agree to the terms and conditions"
end

Given(/^I am not currently waiting for another audio file report$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should be allowed to submit the form$/) do
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

Given(/^the user is currently waiting for another audio file report$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see an error message explaining the status of the project$/) do
  pending # express the regexp above with the code you wish you had
end
