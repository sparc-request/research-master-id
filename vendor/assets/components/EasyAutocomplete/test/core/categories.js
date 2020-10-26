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
 * Tests EasyAutocomplete - categories 
 *
 * @author Łukasz Pawełczak
 */
QUnit.test("Simple category", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				categories: [{
					listLocation: "fruits"
				}],
				url: "resources/categories.json",
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

		assert.equal(4, elements.length, "Response size");
		assert.equal("Apple", elements.eq(0).find("div").text(), "First element value");
		assert.equal("Cherry", elements.eq(1).find("div").text(), "Second element value");
		assert.equal("Honeydew melon", elements.eq(3).find("div").text(), "Last element value");
		
		QUnit.start();	
	}
});

QUnit.test("Simple categories - two list", function( assert ) {
	expect(7);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				categories: [{
					listLocation: "fruits"
				}, {
					listLocation: "vegetables"
				}],
				url: "resources/categories.json",
				ajaxCallback: function() {

					//assert
					assertList();
				},

				list: {
					maxNumberOfElements: 8
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

		assert.equal(8, elements.length, "Response size");
		assert.equal("Apple", elements.eq(0).find("div").text(), "First element value");
		assert.equal("Cherry", elements.eq(1).find("div").text(), "Second element value");
		assert.equal("Honeydew melon", elements.eq(3).find("div").text(), "Last element value");

		assert.equal("Jerusalem artichoke", elements.eq(5).find("div").text(), "Second element value");
		assert.equal("Green bean", elements.eq(6).find("div").text(), "Third element value - second category");
		assert.equal("Fennel", elements.eq(7).find("div").text(), "Fourth element value - second category");


		QUnit.start();	
	}
});

QUnit.test("Simple categories - two list - local data", function( assert ) {
	expect(7);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				categories: [{
					listLocation: "fruits"
				}, {
					listLocation: "vegetables"
				}],

				data: {
					fruits: ["Apple", "Cherry", "Clementine", "Honeydew melon", "Watermelon", "Satsuma"],
					vegetables: ["Pepper", "Jerusalem artichoke", "Green bean", "Fennel", "Courgette", "Yam"]
				},

				list: {
					maxNumberOfElements: 8
				}
	});


	//execute
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("c").trigger(e);


	//assert
	var elements = $("#inputOne").next().find("ul li");

	assert.equal(8, elements.length, "Response size");
	assert.equal("Apple", elements.eq(0).find("div").text(), "First element value");
	assert.equal("Cherry", elements.eq(1).find("div").text(), "Second element value");
	assert.equal("Honeydew melon", elements.eq(3).find("div").text(), "Last element value");

	assert.equal("Jerusalem artichoke", elements.eq(5).find("div").text(), "Second element value");
	assert.equal("Green bean", elements.eq(6).find("div").text(), "Third element value - second category");
	assert.equal("Fennel", elements.eq(7).find("div").text(), "Fourth element value - second category");

});

QUnit.test("Simple category - no list location", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				categories: [{
					getValue: "name"
				}],
				url: "resources/colors.json",
				ajaxCallback: function() {

					//assert
					assertList();
				},

				list: {
					maxNumberOfElements: 8
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
		assert.equal("blue", elements.eq(0).find("div").text(), "First element value");
		assert.equal("yellow", elements.eq(1).find("div").text(), "Second element value");
		assert.equal("brown", elements.eq(2).find("div").text(), "Last element value");
		
		QUnit.start();	
	}
});

QUnit.test("Simple category - with header", function( assert ) {
	expect(6);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				categories: [{
					listLocation: "fruits",
					header: "--- FRUITS ---"
				}],
				url: "resources/categories.json",
				ajaxCallback: function() {

					//assert
					assertList();
				},

				list: {
					maxNumberOfElements: 8
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
		var elements = $("#inputOne").next().find("ul").find(" > div, > li");

		assert.equal(5, elements.length, "Response size");
		assert.equal("--- FRUITS ---", elements.eq(0).text(), "Header");
		assert.equal(true, elements.eq(0).hasClass("eac-category"), "Header - first category");
		assert.equal("Apple", elements.eq(1).find("div").text(), "First element value");
		assert.equal("Cherry", elements.eq(2).find("div").text(), "Second element value");
		assert.equal("Honeydew melon", elements.eq(4).find("div").text(), "Last element value");
		
		QUnit.start();	
	}
});

QUnit.test("Simple category - two categories, with header", function( assert ) {
	expect(7);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				categories: [{
					listLocation: "fruits",
					header: "--- FRUITS ---"
				},{
					listLocation: "vegetables",
					header: "--- vegetables ---"
				}],
				url: "resources/categories.json",
				ajaxCallback: function() {

					//assert
					assertList();
				},

				list: {
					maxNumberOfElements: 8
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
		var elements = $("#inputOne").next().find("ul").find(" > div, > li");

		assert.equal(10, elements.length, "Response size");
		assert.equal("--- FRUITS ---", elements.eq(0).text(), "Header - first category");
		assert.equal(true, elements.eq(0).hasClass("eac-category"), "Header - first category");
		assert.equal("Honeydew melon", elements.eq(4).find("div").text(), "Last element value - first category");
		assert.equal("--- vegetables ---", elements.eq(5).text(), "Header - second category");
		assert.equal(true, elements.eq(5).hasClass("eac-category"), "Header - second category");
		assert.equal("Pepper", elements.eq(6).find("div").text(), "First element value - second category");
		
		QUnit.start();	
	}
});


QUnit.test("Category - data as objects list", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				categories: [{
					listLocation: "fruits"
				}],
				getValue: "name",
				url: "resources/categories/fruits.json",
				ajaxCallback: function() {

					//assert
					assertList();
				},

				list: {
					maxNumberOfElements: 8
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

		assert.equal(4, elements.length, "Response size");
		assert.equal("Apple", elements.eq(0).find("div").text(), "First element value");
		assert.equal("Cherry", elements.eq(1).find("div").text(), "Second element value");
		assert.equal("Honeydew melon", elements.eq(3).find("div").text(), "Last element value");
		
		QUnit.start();	
	}
});

QUnit.test("Category - data as objects list - two different list", function( assert ) {
	expect(7);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				categories: [{
					listLocation: "fruits",
					getValue: "name"
				}, {
					listLocation: "vegetables",
					getValue: function(item) {return item.text;}
				}],

				url: "resources/categories/fruits.json",
				ajaxCallback: function() {

					//assert
					assertList();
				},

				list: {
					maxNumberOfElements: 8
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

		assert.equal(8, elements.length, "Response size");
		assert.equal("Apple", elements.eq(0).find("div").text(), "First element value");
		assert.equal("Cherry", elements.eq(1).find("div").text(), "Second element value");
		assert.equal("Honeydew melon", elements.eq(3).find("div").text(), "Last element value");
		
		assert.equal("Jerusalem artichoke", elements.eq(5).find("div").text(), "First element value - second category");
		assert.equal("Green bean", elements.eq(6).find("div").text(), "Second element value - second category");
		assert.equal("Fennel", elements.eq(7).find("div").text(), "Last element value - second category")


		QUnit.start();	
	}
});

QUnit.test("Category - xml - simple", function( assert ) {
	expect(6);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
	{
		
		categories: [{
			header: "colors"
		}],

		dataType: "xml",
		xmlElementName: "color",	

		url: "resources/colors.xml",
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
		var elements = $("#inputOne").next().find("ul").find(" > div, > li");

		assert.equal(5, elements.length, "Response size");
		assert.equal("colors", elements.eq(0).text(), "Header - first category");
		assert.equal("red", elements.eq(1).find("div").text(), "First element value");
		assert.equal("green", elements.eq(2).find("div").text(), "Second element value");
		assert.equal("blue", elements.eq(3).find("div").text(), "Last element value");
		assert.equal("pink", elements.eq(4).find("div").text(), "Last element value");


		QUnit.start();	
	}
});

QUnit.test("Category - xml - one list", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
	{
		categories: [{
			header: "xml - fruits",	
			listLocation: "fruits"
		}],

		getValue: function(element) { return $(element).find("name").text();},

		dataType: "xml",
		xmlElementName: "fruit",	

		url: "resources/categories/fruits.xml",
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

		assert.equal(4, elements.length, "Response size");
		assert.equal("Apple", elements.eq(0).find("div").text(), "First element value");
		assert.equal("Cherry", elements.eq(1).find("div").text(), "Second element value");
		assert.equal("Honeydew melon", elements.eq(3).find("div").text(), "Last element value");


		QUnit.start();	
	}
});

QUnit.test("Category - xml - two list", function( assert ) {
	expect(7);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
	{
		categories: [{
			header: "xml - fruits",
			listLocation: "fruits",
			xmlElementName: "fruit"
		},{
			header: "xml - vegetables",
			listLocation: "vegetables",
			xmlElementName: "vegetable"
		}],

		getValue: function(element) { return $(element).find("name").text();},

		dataType: "xml",
		xmlElementName: "fruit",	

		url: "resources/categories/fruits.xml",
		ajaxCallback: function() {

			//assert
			assertList();
		},

		list: {
			maxNumberOfElements: 8
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

		assert.equal(8, elements.length, "Response size");
		assert.equal("Apple", elements.eq(0).find("div").text(), "First element value");
		assert.equal("Cherry", elements.eq(1).find("div").text(), "Second element value");
		assert.equal("Honeydew melon", elements.eq(3).find("div").text(), "Last element value");

		assert.equal("Carrot", elements.eq(4).find("div").text(), "First element value");
		assert.equal("Tomato", elements.eq(5).find("div").text(), "Second element value");
		assert.equal("Cucamber", elements.eq(7).find("div").text(), "Last element value");


		QUnit.start();	
	}
});

QUnit.test("Category and processData - sort", function( assert ) {
	expect(9);

	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				categories: [{
					listLocation: "fruits",
					header: "--- FRUITS ---"
				},{
					listLocation: "vegetables",
					header: "--- vegetables ---"
				}],
				url: "resources/categories.json",

				list: {
					sort: {
						enabled: true
					},
					maxNumberOfElements: 8
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
		var elements = $("#inputOne").next().find("ul").find(" > div, > li");

		assert.equal(10, elements.length, "Response size");
		assert.equal("--- FRUITS ---", elements.eq(0).text(), "Header - first category");
		assert.equal("Apple", elements.eq(1).find("div").text(), "Apple element value - first category");
		assert.equal("Cherry", elements.eq(2).find("div").text(), "Cherry element value - first category");
		assert.equal("Clementine", elements.eq(3).find("div").text(), "Clementine element value - first category");
		assert.equal("Honeydew melon", elements.eq(4).find("div").text(), "Honeydew melon element value - first category");
		assert.equal("--- vegetables ---", elements.eq(5).text(), "Header - second category");
		assert.equal("Fennel", elements.eq(6).find("div").text(), "Courgette element value - second category");
		assert.equal("Green bean", elements.eq(7).find("div").text(), "Fennel element value - second category");
		
		QUnit.start();	
	}
});


QUnit.test("Category and processData - match", function( assert ) {
	expect(9);

	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				categories: [{
					listLocation: "fruits",
					header: "--- FRUITS ---"
				},{
					listLocation: "vegetables",
					header: "--- vegetables ---"
				}],
				url: "resources/categories.json",

				list: {
					match: {
						enabled: true
					}
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
	$("#inputOne").val("a").trigger(e);


	QUnit.stop();


	//assert
	function assertList() {
		var elements = $("#inputOne").next().find("ul").find(" > div, > li");

		assert.equal(8, elements.length, "Response size");
		assert.equal("--- FRUITS ---", elements.eq(0).text(), "Header - first category");
		assert.equal("Apple", elements.eq(1).find("div").text(), "Apple element value - first category");
		assert.equal("Watermelon", elements.eq(2).find("div").text(), "Watermelon element value - first category");
		assert.equal("Satsuma", elements.eq(3).find("div").text(), "Satsuma element value - first category");
		assert.equal("--- vegetables ---", elements.eq(4).text(), "Header - second category");
		assert.equal("Jerusalem artichoke", elements.eq(5).find("div").text(), "Jerusalem artichoke element value - second category");
		assert.equal("Green bean", elements.eq(6).find("div").text(), "Green bean element value - second category");
		assert.equal("Yam", elements.eq(7).find("div").text(), "Yam element value - second category");
		
		QUnit.start();	
	}
});

QUnit.test("Category and processData - maxNumberOfElements - default", function( assert ) {
	expect(9);

	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				categories: [{
					listLocation: "fruits",
					header: "--- FRUITS ---"
				},{
					listLocation: "vegetables",
					header: "--- vegetables ---"
				}],
				url: "resources/categories.json",

				list: {
					maxNumberOfElements: 6
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
	$("#inputOne").val("a").trigger(e);


	QUnit.stop();


	//assert
	function assertList() {
		var elements = $("#inputOne").next().find("ul").find(" > div, > li");

		assert.equal(8, elements.length, "Response size");
		assert.equal("--- FRUITS ---", elements.eq(0).text(), "Header - first category");
		assert.equal("Apple", elements.eq(1).find("div").text(), "Apple element value - first category");
		assert.equal("Cherry", elements.eq(2).find("div").text(), "Cherry element value - first category");
		assert.equal("Clementine", elements.eq(3).find("div").text(), "Clementine element value - first category");
		assert.equal("Honeydew melon", elements.eq(4).find("div").text(), "Honeydew melon element value - first category");
		assert.equal("--- vegetables ---", elements.eq(5).text(), "Header - second category");
		assert.equal("Pepper", elements.eq(6).find("div").text(), "Pepper element value - second category");
		assert.equal("Jerusalem artichoke", elements.eq(7).find("div").text(), "Jerusalem artichoke element value - second category");
		
		QUnit.start();	
	}
});

QUnit.test("Category and processData - maxNumberOfElements - specified - list size default", function( assert ) {
	expect(8);

	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				categories: [{
					listLocation: "fruits",
					header: "--- FRUITS ---",
					maxNumberOfElements: 2
				},{
					listLocation: "vegetables",
					header: "--- vegetables ---",
					maxNumberOfElements: 3
				}],
				url: "resources/categories.json",

				ajaxCallback: function() {

					//assert
					assertList();
				}
	});


	//execute
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("a").trigger(e);


	QUnit.stop();


	//assert
	function assertList() {
		var elements = $("#inputOne").next().find("ul").find(" > div, > li");

		assert.equal(7, elements.length, "Response size");
		assert.equal("--- FRUITS ---", elements.eq(0).text(), "Header - first category");
		assert.equal("Apple", elements.eq(1).find("div").text(), "Apple element value - first category");
		assert.equal("Cherry", elements.eq(2).find("div").text(), "Cherry element value - first category");
		assert.equal("--- vegetables ---", elements.eq(3).text(), "Header - second category");
		assert.equal("Pepper", elements.eq(4).find("div").text(), "Pepper element value - second category");
		assert.equal("Jerusalem artichoke", elements.eq(5).find("div").text(), "Jerusalem artichoke element value - second category");
		assert.equal("Green bean", elements.eq(6).find("div").text(), "Green bean element value - second category");
		
		QUnit.start();	
	}
});


QUnit.test("Category and processData - maxNumberOfElements - specified - list size specified", function( assert ) {
	expect(7);

	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				categories: [{
					listLocation: "fruits",
					header: "--- FRUITS ---",
					maxNumberOfElements: 2
				},{
					listLocation: "vegetables",
					header: "--- vegetables ---",
					maxNumberOfElements: 3
				}],
				url: "resources/categories.json",

				
				list: {
					maxNumberOfElements: 4
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
	$("#inputOne").val("a").trigger(e);


	QUnit.stop();


	//assert
	function assertList() {
		var elements = $("#inputOne").next().find("ul").find(" > div, > li");

		assert.equal(6, elements.length, "Response size");
		assert.equal("--- FRUITS ---", elements.eq(0).text(), "Header - first category");
		assert.equal("Apple", elements.eq(1).find("div").text(), "Apple element value - first category");
		assert.equal("Cherry", elements.eq(2).find("div").text(), "Cherry element value - first category");
		assert.equal("--- vegetables ---", elements.eq(3).text(), "Header - second category");
		assert.equal("Pepper", elements.eq(4).find("div").text(), "Pepper element value - second category");
		assert.equal("Jerusalem artichoke", elements.eq(5).find("div").text(), "Jerusalem artichoke element value - second category");
		
		QUnit.start();	
	}
});



QUnit.test("Categories - when list ist empty, header should be hidden", function( assert ) {
	expect(5);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), 
			{
				categories: [{
					listLocation: "fruits"
				}, {
					listLocation: "vegetables",
					header: "--- vegetables ---"
				}],

				data: {
					fruits: [],
					vegetables: ["Pepper", "Jerusalem artichoke", "Green bean", "Fennel", "Courgette", "Yam"]
				}
	});


	//execute
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("c").trigger(e);


	//assert
	var elements = $("#inputOne").next().find("ul").find(" > div, > li");

	assert.equal(5, elements.length, "Response size");
	assert.equal("--- vegetables ---", elements.eq(0).text(), "Header - second category");
	assert.equal("Pepper", elements.eq(1).find("div").text(), "First element value - second category");
	assert.equal("Jerusalem artichoke", elements.eq(2).find("div").text(), "Second element value - second category");
	assert.equal("Green bean", elements.eq(3).find("div").text(), "Last element value - second category")

});