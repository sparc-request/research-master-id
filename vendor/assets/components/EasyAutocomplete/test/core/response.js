// Copyright © 2011-2020 MUSC Foundation for Research Development~
// All rights reserved.~

// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

// 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

// 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
// disclaimer in the documentation and/or other materials provided with the distribution.~

// 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
// derived from this software without specific prior written permission.~

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
// BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
// SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
// TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

/*
 * Tests EasyAutocomplete - response 
 *
 * @author Łukasz Pawełczak
 */
QUnit.test("Ajax settings - no url", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				url: "", 
				ajaxSettings: {
					url: "resources/colors_string.json"
				},
				ajaxCallback: function() {

					//assert
					assertList();
				}
	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("c").trigger(e);


	QUnit.stop();


	//assert

	function assertList() {
		var elements = $("#inputOne").next().find("ul li");

			assert.equal(3, elements.length, "Response size");
			assert.equal("red", elements.eq(0).find("div").text(), "First element value");
			assert.equal("yellow", elements.eq(1).find("div").text(), "Second element value");
			assert.equal("brown", elements.eq(2).find("div").text(), "Third element value");
			
			QUnit.start();	
	}
});

QUnit.test("Ajax settings - two urls", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				url: "resources/countries.json", 
				ajaxSettings: {
					url: "resources/colors_string.json", 
				},
				ajaxCallback: function() {

					//assert
					assertList();
				}
	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("c").trigger(e);


	QUnit.stop();


	//assert

	function assertList() {
		var elements = $("#inputOne").next().find("ul li");

			assert.equal(3, elements.length, "Response size");
			assert.equal("red", elements.eq(0).find("div").text(), "First element value");
			assert.equal("yellow", elements.eq(1).find("div").text(), "Second element value");
			assert.equal("brown", elements.eq(2).find("div").text(), "Third element value");
			
			QUnit.start();	
	}
});


QUnit.test("Ajax settings - settings url is function", function( assert ) {
	expect(8);
	


	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				url: "resources/countries.json", 
				ajaxSettings: {
					url: function(phrase) { return "resources/colors_string.json";}, 
				},
				ajaxCallback: function() {

					//assert
					assertList();
				}
	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("c").trigger(e);
	

	QUnit.stop();


	$("#inputOne").val("c").trigger(e);
	

	QUnit.stop();


	//assert

	function assertList() {
		var elements = $("#inputOne").next().find("ul li");

			assert.equal(3, elements.length, "Response size");
			assert.equal("red", elements.eq(0).find("div").text(), "First element value");
			assert.equal("yellow", elements.eq(1).find("div").text(), "Second element value");
			assert.equal("brown", elements.eq(2).find("div").text(), "Third element value");
			
			QUnit.start();	
	}
});


QUnit.test("Do not match response", function( assert ) {
	expect(1);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				url: "resources/response.json", 

				listLocation: "items",
				
				matchResponseProperty: "inputPhrase",

				ajaxCallback: function() {

					//assert
					assertList();
				}
	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("r").trigger(e);


	QUnit.stop();


	//assert

	function assertList() {
		var elements = $("#inputOne").next().find("ul li");

			assert.equal(0, elements.length, "Response size");
			
			QUnit.start();	
	}
});

QUnit.test("Match response", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				url: "resources/response.json", 

				listLocation: "items",
				
				matchResponseProperty: "inputPhrase",

				ajaxCallback: function() {

					//assert
					assertList();
				}
	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("rr").trigger(e);


	QUnit.stop();


	//assert

	function assertList() {
		var elements = $("#inputOne").next().find("ul li");

			assert.equal(3, elements.length, "Response size");
			assert.equal("red", elements.eq(0).find("div").text(), "First element value");
			assert.equal("yellow", elements.eq(1).find("div").text(), "Second element value");
			assert.equal("brown", elements.eq(2).find("div").text(), "Third element value");
			
			QUnit.start();	
	}
});

QUnit.test("Match response - property function", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				url: "resources/response.json", 

				listLocation: "items",
				
				matchResponseProperty: function(data) {
					return data.inputPhrase;
				},

				ajaxCallback: function() {

					//assert
					assertList();
				}
	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("rr").trigger(e);


	QUnit.stop();


	//assert

	function assertList() {
		var elements = $("#inputOne").next().find("ul li");

			assert.equal(3, elements.length, "Response size");
			assert.equal("red", elements.eq(0).find("div").text(), "First element value");
			assert.equal("yellow", elements.eq(1).find("div").text(), "Second element value");
			assert.equal("brown", elements.eq(2).find("div").text(), "Third element value");
			
			QUnit.start();	
	}
});

QUnit.test("Input field should have value changed when user clicks on one element from suggestions list", function( assert ) {
	expect(1);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				url: "resources/colors.json", 

				getValue: "name",

				ajaxCallback: function() {

					var elements = $input.next().find("ul li");
					//selects first element
					elements.eq(0).find("div").click();

					//assert
					assert.equal("blue", $input.val());			

					QUnit.start();	
				}
	});


	//execute
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	var $input = $("#inputOne").val("rr").trigger(e);


	QUnit.stop();

});


QUnit.test("Input field should trigger change event when user clicks on one element from suggestions list", function( assert ) {
	expect(1);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				url: "resources/colors.json", 

				getValue: "name",

				ajaxCallback: function() {

					var elements = $input.next().find("ul li");
					//selects first element
					elements.eq(0).find("div").click();


					//assert		
					assert.equal(true, flag);

					QUnit.start();	
				}
	}),
		flag = false,
		$input = $("#inputOne");


	$input.change(function() {
		flag = true;
	});


	//execute
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$input.val("rr").trigger(e);



	QUnit.stop();

});


