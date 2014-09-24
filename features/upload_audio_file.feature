Feature: Upload audio file

	Users need to be able to upload one audio file at a time to the website.
	
	Scenario: Submit one audio file
		* I have provided a valid audio file or URL
		* The audio file is in a valid format
		* I am not currently waiting for another audio file report
		* The audio file is below the maximum file size
		* I have entered a valid email address
		* I have agreed to the terms and conditions
		* I have selected at least one test {wind noise, handling noise, distortion}
		Then I should be shown a confirmation and told to wait for an email containing a link to the audio file report
		And given an estimate of how long it will take to get the audio file report

	Scenario: User is currently waiting for another audio file report
		Given the user is currently waiting for another audio file report
		Then I should see an error message explaining the status of the project