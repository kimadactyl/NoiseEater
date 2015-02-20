Feature: Upload audio file
	In order to clean my audio files from noise
	As a user
	I want to upload audio files to the app

	Scenario: View submission form
		Given I am on the homepage
		Then I should see "Audio:" in the selector "label"
		And I should see "Email:" in the selector "label"
	
	Scenario: Submit audio file
		Given I am on the homepage
		* I have provided a valid audio file or URL 
		* The audio file is below the maximum file size
		* I have entered a valid email address
		* I have agreed to the terms and conditions
		* I have selected at least one test {wind noise, handling noise, distortion}
		* I am not currently waiting for another audio file report
		Then I should be shown a confirmation 
		And told to wait for an email containing a link to the audio file report
		And given an estimate of how long it will take to get the audio file report

	Scenario: Audio file is an invalid format
		Given I have provided an invalid audio file or URL
		Then I should be told the format is incorrect

	Scenario: Invalid email addres
		Given I have provided an invalid email address
		Then I should be promoted to correct my email address

	Scenario: User is currently waiting for another audio file report
		Given the user is currently waiting for another audio file report
		Then I should see an error message explaining the status of the project