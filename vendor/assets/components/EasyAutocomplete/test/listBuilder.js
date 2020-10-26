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
 * Tests for ListBuilder module - EasyAutocomplete 
 *
 * @author Łukasz Pawełczak
 */
QUnit.test("ListBuilder", function( assert ) {




	//execute
	var ListBuilderService = new EasyAutocomplete.ListBuilderService();


	//assert
	assert.ok(typeof EasyAutocomplete.ListBuilderService === "function", "Constructor found");
	assert.ok(ListBuilderService, "Constructor");
	assert.ok(typeof ListBuilderService === "object", "created object");
	assert.ok(typeof ListBuilderService.init === "function", "ListBuilderService has method init");
	assert.ok(typeof ListBuilderService.updateCategories === "function", "ListBuilderService has method updateCategories");
	assert.ok(typeof ListBuilderService.convertXml === "function", "ListBuilderService has method convertXml");
	assert.ok(typeof ListBuilderService.processData === "function", "ListBuilderService has method processData");
	assert.ok(typeof ListBuilderService.checkIfDataExists === "function", "ListBuilderService has method checkIfDataExists");
	expect(8);
});



QUnit.test("ListBuilder - init", function( assert ) {

	//given
	var data = {};

	var configuration = {

		get: function(property) {

			switch(property) {

				case "listLocation":
					return function(arg) {
						return data;
					};
				break;

				case "getValue": 
					return function(foo) {return "bar"};
				break;

				case "list": 
					return {maxNumberOfElements: function() {return 3}};
				break;

				default:
				break;
			}
		}
		
	};


	//execute
	var ListBuilderService = new EasyAutocomplete.ListBuilderService(configuration);

	var listBuilders = ListBuilderService.init(data);

	//assert
	assert.ok(listBuilders.length === 1, "ListBuilder - size");
	assert.ok(listBuilders[0].data === data, "ListBuilder - data match");
	assert.ok(listBuilders[0].getValue.toString() == configuration.get("getValue").toString(), "ListBuilder - getValue function match");
	expect(3);
});


QUnit.test("ListBuilder - checkIfDataExists - empty listBuilders", function( assert ) {

	//given
	var configuration = {},
		listBuilders = [{}];


	//execute
	var ListBuilderService = new EasyAutocomplete.ListBuilderService(configuration);

	var flag = ListBuilderService.checkIfDataExists(listBuilders);

	//assert
	assert.ok(flag === false, "checkIfDataExists");
	expect(1);
});

QUnit.test("ListBuilder - checkIfDataExists - listBuilders.data not array", function( assert ) {

	//given
	var configuration = {},
		listBuilders = [{
			data: 1
		}];


	//execute
	var ListBuilderService = new EasyAutocomplete.ListBuilderService(configuration);

	var flag = ListBuilderService.checkIfDataExists(listBuilders);

	//assert
	assert.ok(flag === false, "checkIfDataExists");
	expect(1);
});

QUnit.test("ListBuilder - checkIfDataExists - listBuilders.data array", function( assert ) {

	//given
	var configuration = {},
		listBuilders = [{
			data: [1, 2]
		}];


	//execute
	var ListBuilderService = new EasyAutocomplete.ListBuilderService(configuration);

	var flag = ListBuilderService.checkIfDataExists(listBuilders);

	//assert
	assert.ok(flag === true, "checkIfDataExists");
	expect(1);
});

/*
QUnit.test("ListBuilder - convertXml", function( assert ) {

	//given
	var data = {};

	var configuration = {

		dataType: "xml",

		get: function(property) {

			switch(property) {

				case "listLocation":
					return function(arg) {
						return data;
					}
				break;

				case "getValue": 
					return function(foo) {return "bar"};
				break;

				default:
				break;
			};
		}
		
	};

	var listBuilders = {};


	//execute
	var ListBuilderService = new EasyAutocomplete.ListBuilderService(configuration);

	//var listBuilders = ListBuilderService.init(data);




	//assert
	assert.ok(listBuilders.length === 1, "ListBuilder - size");
	assert.ok(listBuilders[0].data === data, "ListBuilder - data match");
	assert.ok(listBuilders[0].getValue.toString() == configuration.get("getValue").toString(), "ListBuilder - getValue function match");
	expect(3);
});
*/
