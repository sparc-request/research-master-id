// Copyright © 2020 MUSC Foundation for Research Development~
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
 * Tests EasyAutocomplete - response_remote
 *
 * @author Łukasz Pawełczak
 */
QUnit.test("Remote service - Json countries", function( assert ) {
	expect(5);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		url: function(phrase) {
			return "remote/countrySelectService.php?phrase=" + phrase + "&dataType=json";
		},

		getValue: function(element) {
			return element.name;
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
	$("#inputOne").val("po").trigger(e);


	QUnit.stop();

	//assert

	function assertList() {
		var elements = $("#inputOne").next().find("ul li");

		assert.equal(4, elements.length, "Response size");
		assert.equal("FRENCH POLYNESIA", elements.eq(0).find("div").text(), "First element value");
		assert.equal("POLAND", elements.eq(1).find("div").text(), "Second element value");
		assert.equal("PORTUGAL", elements.eq(2).find("div").text(), "Third element value");
		assert.equal("SINGAPORE", elements.eq(3).find("div").text(), "Fourth element value");
			
		QUnit.start();	
	}	
});

QUnit.test("Remote service - Json countries - no match", function( assert ) {
	expect(1);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		url: function(phrase) {
			return "remote/countrySelectService.php?phrase=" + phrase + "&dataType=json";
		},

		getValue: function(element) {
			return element.name;
		},

		ajaxCallback: function() {

			//assert
			
			assertList();
		},
	    list: {
	        match: {
	            enabled: true
	        }
	    }

	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("poli").trigger(e);


	QUnit.stop();

	//assert

	function assertList() {
		var elements = $("#inputOne").next().find("ul li");

		assert.equal(0, elements.length, "Response size");
			
		QUnit.start();	
	}	
});

QUnit.test("Remote service - XML countries", function( assert ) {
	expect(5);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		url: function(phrase) {
			return "remote/countrySelectService.php?phrase=" + phrase + "&dataType=xml";
		},

		dataType: "xml",
		xmlElementName: "country",

		getValue: function(element) {
			return $(element).text();
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
	$("#inputOne").val("po").trigger(e);


	QUnit.stop();

	//assert

	function assertList() {
		var elements = $("#inputOne").next().find("ul li");

		assert.equal(4, elements.length, "Response size");
		assert.equal("FRENCH POLYNESIA", elements.eq(0).find("div").text(), "First element value");
		assert.equal("POLAND", elements.eq(1).find("div").text(), "Second element value");
		assert.equal("PORTUGAL", elements.eq(2).find("div").text(), "Third element value");
		assert.equal("SINGAPORE", elements.eq(3).find("div").text(), "Fourth element value");
			
		QUnit.start();	
	}	
});

QUnit.test("Remote service - Json countries - post data", function( assert ) {
	expect(5);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		url: function(phrase) {
			return "remote/countrySelectService.php";
		},

		getValue: function(element) {
			return element.name;
		},

		ajaxCallback: function() {

			//assert
			
			assertList();
		},

		ajaxSettings: {
			dataType: 'json',
			method: 'POST',
			data: {
				country: "NL",
				postCode:  "test",
				dataType: "json"
			}
		},

		preparePostData: function(data, inputPhrase) {

			data.phrase = $("#inputTwo").val() + inputPhrase;

			return data;
		}

	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputTwo").val("p").trigger("change");
	$("#inputOne").val("o").trigger(e);


	QUnit.stop();

	//assert

	function assertList() {
		var elements = $("#inputOne").next().find("ul li");

		assert.equal(4, elements.length, "Response size");
		assert.equal("FRENCH POLYNESIA", elements.eq(0).find("div").text(), "First element value");
		assert.equal("POLAND", elements.eq(1).find("div").text(), "Second element value");
		assert.equal("PORTUGAL", elements.eq(2).find("div").text(), "Third element value");
		assert.equal("SINGAPORE", elements.eq(3).find("div").text(), "Fourth element value");
			
		QUnit.start();	
	}	
});


