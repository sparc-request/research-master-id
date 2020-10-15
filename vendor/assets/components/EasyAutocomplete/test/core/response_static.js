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
 * Tests EasyAutocomplete - static data
 *
 * @author Łukasz Pawełczak
 */
 QUnit.test("Local data - empty array", function( assert ) {
	expect(1);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		data: [],

	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("a").trigger(e);

	
	//assert
	var elements = $("#inputOne").next().find("ul li");

	assert.equal(0, elements.length, "Response size");
			
});

QUnit.test("Local data - string array", function( assert ) {
	expect(5);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		data: ["red", "green", "blue", "pink"],

	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("a").trigger(e);
	$("#inputOne").val("a").trigger(e);

	
	//assert

	var elements = $("#inputOne").next().find("ul li");

	assert.equal(4, elements.length, "Response size");
	assert.equal("red", elements.eq(0).find("div").text(), "First element value");
	assert.equal("green", elements.eq(1).find("div").text(), "Second element value");
	assert.equal("blue", elements.eq(2).find("div").text(), "Third element value");
	assert.equal("pink", elements.eq(3).find("div").text(), "Fourth element value");
		
});

QUnit.test("Local data - object array", function( assert ) {
	expect(5);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		data: [{"name": "red"}, {"name": "green"}, {"name": "blue"}, {"name": "pink"}],

		getValue: function(element) {
			return element.name;
		},
	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("").trigger(e);


	//assert


	var elements = $("#inputOne").next().find("ul li");

	assert.equal(4, elements.length, "Response size");
	assert.equal("red", elements.eq(0).find("div").text(), "First element value");
	assert.equal("green", elements.eq(1).find("div").text(), "Second element value");
	assert.equal("blue", elements.eq(2).find("div").text(), "Third element value");
	assert.equal("pink", elements.eq(3).find("div").text(), "Fourth element value");
		
	
});

QUnit.test("Local data + listLocation- string array", function( assert ) {
	expect(5);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		data: {
			colors: ["black", "white", "magenta", "yellow"]
		},

		listLocation: "colors"

	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("a").trigger(e);
	$("#inputOne").val("a").trigger(e);

	
	//assert

	var elements = $("#inputOne").next().find("ul li");

	assert.equal(4, elements.length, "Response size");
	assert.equal("black", elements.eq(0).find("div").text(), "First element value");
	assert.equal("white", elements.eq(1).find("div").text(), "Second element value");
	assert.equal("magenta", elements.eq(2).find("div").text(), "Third element value");
	assert.equal("yellow", elements.eq(3).find("div").text(), "Fourth element value");
		
});

QUnit.test("Local data + listLocation - object array", function( assert ) {
	expect(5);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		data: {
			colors: [{"name": "red"}, {"name": "green"}, {"name": "blue"}, {"name": "pink"}],
			otherStaff: "foo bar"
		},

		getValue: function(element) {
			return element.name;
		},

		listLocation: "colors"
	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("").trigger(e);


	//assert


	var elements = $("#inputOne").next().find("ul li");

	assert.equal(4, elements.length, "Response size");
	assert.equal("red", elements.eq(0).find("div").text(), "First element value");
	assert.equal("green", elements.eq(1).find("div").text(), "Second element value");
	assert.equal("blue", elements.eq(2).find("div").text(), "Third element value");
	assert.equal("pink", elements.eq(3).find("div").text(), "Fourth element value");
		
	
});
