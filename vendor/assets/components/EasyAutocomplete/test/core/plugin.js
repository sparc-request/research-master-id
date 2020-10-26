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
 * Tests EasyAutocomplete - plugin
 *
 * @author Łukasz Pawełczak
 */
QUnit.test( "JQuery method exists", function( assert ) {


	//assert
	assert.ok($.fn.easyAutocomplete, "Method $.easyAutocomplete exists");
	assert.ok($.fn.getSelectedItemIndex, "Method $.getSelectedItemIndex exists");
	assert.ok($.fn.getItemData, "Method $.getItemData exists");
	assert.ok($.fn.getSelectedItemData, "Method $.getSelectedItemData exists");
	expect(4);
});


QUnit.test("Input field has no id property", function( assert ) {
	
	
	//given
	$(".inputOne").attr("id", "");

	var completerOne = $(".inputOne").easyAutocomplete({

		data: ["black", "white", "magenta", "yellow"],
		
	});


	//execute
	var e = $.Event('keyup');
	e.keyCode = 50; 
	$(".inputOne").val("a").trigger(e);

	//assert
	var elements = $(".inputOne").next().find("ul li");

	assert.equal(4, elements.length, "Response size");
	assert.equal("black", elements.eq(0).text(), "First element is 'black'");
	assert.equal("white", elements.eq(1).text(), "Second element is 'white'");
	assert.equal("magenta", elements.eq(2).text(), "Third element is 'magenta'");
	assert.equal("yellow", elements.eq(3).text(), "Fourth element is 'yellow'");

	assert.ok($(".inputOne").attr("id").length > 0, "id is defined");	

	expect(6);
});

QUnit.test("Invoke plugin function on input that is dynamically added", function( assert ) {
	
	
	//given

	//create text field
	var $dynamicInput = $("<input type='text' />").attr("id", "inputThree");

	$(".inputOne").after($dynamicInput);

	var completerOne = $("#inputThree").easyAutocomplete({

		data: ["black", "white", "magenta", "yellow"],
		
	});


	//execute
	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputThree").val("more").trigger(e);

	//assert
	var elements = $("#inputThree").next().find("ul li");

	assert.equal(4, elements.length, "Response size");
	assert.equal("black", elements.eq(0).text(), "First element is 'black'");
	assert.equal("white", elements.eq(1).text(), "Second element is 'white'");
	assert.equal("magenta", elements.eq(2).text(), "Third element is 'magenta'");
	assert.equal("yellow", elements.eq(3).text(), "Fourth element is 'yellow'");

	expect(5);
});

QUnit.test(".easyAutocomplete function should return jQuery object", function( assert ) {
	
	
	//given
	$("#inputThree").attr("justice", "");


	//execute
	var completerOne = $("#inputThree").easyAutocomplete({

		data: ["black", "white", "magenta", "yellow"],

		list: {

			match: {
				enabled: true
			}
		}
		
	})
	.attr("justice", "beaver");

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputThree").val("a").trigger(e);

	//assert
	var elements = $("#inputThree").next().find("ul li");

	assert.equal("beaver", $("#inputThree").attr("justice"), "Setted attribute.");
	assert.equal(2, elements.length, "Response size");
	assert.equal("black", elements.eq(0).text(), "First element is 'black'");
	assert.equal("magenta", elements.eq(1).text(), "Second element is 'magenta'");

	expect(4);
});



