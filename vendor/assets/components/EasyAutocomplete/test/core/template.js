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
QUnit.test("Template - basic", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		data: ["red", "green", "blue", "pink"],

		template: {}

	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("a").trigger(e);

	
	//assert

	var elements = $("#inputOne").next().find("ul li");

	assert.ok($("#inputOne").parent().hasClass("undefined") === false, "There is no class undefined");

	assert.equal(4, elements.length, "Response size");
	assert.equal("red", elements.eq(0).find("div").text(), "First element value");
	assert.equal("green", elements.eq(1).find("div").text(), "Second element value");

		
});



QUnit.test("Template - description", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		data: [{country: "Poland", code: "pol"}, {country: "Germany", code: "ger"}, {country: "Italy", code: "ita"}],

		getValue: "country",

		template: {
			type: "description",
			fields: {
				description: "code"
			}
		}

	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("a").trigger(e);

	
	//assert

	var elements = $("#inputOne").next().find("ul li");

	assert.equal(3, elements.length, "Response size");
	assert.equal("Poland - pol", elements.eq(0).find("div").text(), "First element value");
	assert.equal("Germany - ger", elements.eq(1).find("div").text(), "Second element value");
	assert.ok(true === $("#inputOne").parent().hasClass("eac-description"), "CSS class");

		
});

QUnit.test("Template - description - function", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		data: [{country: "Poland", code: "pol"}, {country: "Germany", code: "ger"}, {country: "Italy", code: "ita"}],

		getValue: "country",

		template: {
			type: "description",
			fields: {
				description: function(element) {return element.code;}
			}
		}

	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("a").trigger(e);

	
	//assert

	var elements = $("#inputOne").next().find("ul li");

	assert.equal(3, elements.length, "Response size");
	assert.equal("Poland - pol", elements.eq(0).find("div").text(), "First element value");
	assert.equal("Germany - ger", elements.eq(1).find("div").text(), "Second element value");
	assert.ok(true === $("#inputOne").parent().hasClass("eac-description"), "CSS class");

		
});


QUnit.test("Template - icon right - iconSrc string", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		data: [{country: "Poland", code: "pol"}, {country: "Germany", code: "ger"}, {country: "Italy", code: "ita"}],

		getValue: "country",

		template: {
			type: "iconRight",
			fields: {
				iconSrc: "code"
			}
		}

	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("z").trigger(e);

	
	//assert

	var elements = $("#inputOne").next().find("ul li");

	assert.equal(3, elements.length, "Response size");
	assert.equal("Poland<img class=\"eac-icon\" src=\"pol\">", elements.eq(0).find("div").html(), "First element value");
	assert.equal("Germany<img class=\"eac-icon\" src=\"ger\">", elements.eq(1).find("div").html(), "Second element value");
	assert.ok(true == $("#inputOne").parent().hasClass("eac-icon-right"), "CSS class");

		
});



QUnit.test("Template - icon right - iconSrc function", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		data: [{country: "Poland", code: "pol"}, {country: "Germany", code: "ger"}, {country: "Italy", code: "ita"}],

		getValue: "country",

		template: {
			type: "iconRight",
			fields: {
				iconSrc: function(element) {
					return "http://iconSource.info/" + element.code + ".png";
				}
			}
		}

	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("z").trigger(e);

	
	//assert

	var elements = $("#inputOne").next().find("ul li");

	assert.equal(3, elements.length, "Response size");
	assert.equal("Poland<img class=\"eac-icon\" src=\"http://iconSource.info/pol.png\">", elements.eq(0).find("div").html(), "First element value");
	assert.equal("Germany<img class=\"eac-icon\" src=\"http://iconSource.info/ger.png\">", elements.eq(1).find("div").html(), "Second element value");
	assert.ok(true == $("#inputOne").parent().hasClass("eac-icon-right"), "CSS class");

		
});


QUnit.test("Template - icon left - iconSrc function", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		data: [{country: "Poland", code: "pol"}, {country: "Germany", code: "ger"}, {country: "Italy", code: "ita"}],

		getValue: "country",

		template: {
			type: "iconLeft",
			fields: {
				iconSrc: function(element) {
					return "http://iconSource.info/" + element.code + ".png";
				}
			}
		}

	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("z").trigger(e);

	
	//assert

	var elements = $("#inputOne").next().find("ul li");

	assert.equal(3, elements.length, "Response size");
	assert.equal("<img class=\"eac-icon\" src=\"http://iconSource.info/pol.png\">Poland", elements.eq(0).find("div").html(), "First element value");
	assert.equal("<img class=\"eac-icon\" src=\"http://iconSource.info/ger.png\">Germany", elements.eq(1).find("div").html(), "Second element value");
	assert.ok(true == $("#inputOne").parent().hasClass("eac-icon-left"), "CSS class");
	
});

QUnit.test("Template - icon left - iconSrc string", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		data: [{country: "Poland", code: "pol"}, {country: "Germany", code: "ger"}, {country: "Italy", code: "ita"}],

		getValue: "country",

		template: {
			type: "iconLeft",
			fields: {
				iconSrc: "code"
			}
		}

	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("z").trigger(e);

	
	//assert

	var elements = $("#inputOne").next().find("ul li");

	assert.equal(3, elements.length, "Response size");
	assert.equal("<img class=\"eac-icon\" src=\"pol\">Poland", elements.eq(0).find("div").html(), "First element value");
	assert.equal("<img class=\"eac-icon\" src=\"ger\">Germany", elements.eq(1).find("div").html(), "Second element value");
	assert.ok(true == $("#inputOne").parent().hasClass("eac-icon-left"), "CSS class");
	
});

QUnit.test("Template - icon left - xml provider - complex data", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		url: "resources/colors_object.xml",

		dataType: "xml",
		xmlElementName: "color",

		getValue: function(element) {
			return $(element).find("name").text();
		},

		template: {
			type: "iconLeft",
			fields: {
				iconSrc: function(element) {
					return $(element).find("name").text();
				}
			}
		},

		list: {
			match: {
				enabled: false
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
	$("#inputOne").val("z").trigger(e);

	
	QUnit.stop();
	
	//assert
	function assertList() {
		var elements = $("#inputOne").next().find("ul li");

		assert.ok($("#inputOne").parent().hasClass("undefined") === false, "There is no class undefined");

		assert.equal(4, elements.length, "Response size");
		assert.equal("<img class=\"eac-icon\" src=\"red\">red", elements.eq(0).find("div").html(), "First element value");
		assert.equal("<img class=\"eac-icon\" src=\"green\">green", elements.eq(1).find("div").html(), "Second element value");

		QUnit.start();
	}
});


QUnit.test("Template - links - link string", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		data: [{country: "Poland", site: "http://site.pl"}, {country: "Germany", site: "http://site.de"}, {country: "Italy", site: "http://site.it"}],

		getValue: "country",

		template: {
			type: "links",
			fields: {
				link: "site"
			}
		}

	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("z").trigger(e);

	
	//assert

	var elements = $("#inputOne").next().find("ul li");

	assert.ok($("#inputOne").parent().hasClass("undefined") === false, "There is no class undefined");

	assert.equal(3, elements.length, "Response size");
	assert.equal("<a href=\"http://site.pl\">Poland</a>", elements.eq(0).find("div").html(), "First element value");
	assert.equal("<a href=\"http://site.de\">Germany</a>", elements.eq(1).find("div").html(), "Second element value");
	
});


QUnit.test("Template - links - link function", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		data: [{country: "Poland", site: "pl"}, {country: "Germany", site: "de"}, {country: "Italy", site: "it"}],

		getValue: "country",

		template: {
			type: "links",
			fields: {
				link: function(element) {
					return "http://site." + element.site;
				}
			}
		}

	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("z").trigger(e);

	
	//assert

	var elements = $("#inputOne").next().find("ul li");

	assert.ok($("#inputOne").parent().hasClass("undefined") === false, "There is no class undefined");

	assert.equal(3, elements.length, "Response size");
	assert.equal("<a href=\"http://site.pl\">Poland</a>", elements.eq(0).find("div").html(), "First element value");
	assert.equal("<a href=\"http://site.de\">Germany</a>", elements.eq(1).find("div").html(), "Second element value");
	
});


QUnit.test("Template - links - xml provider - complex data", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		url: "resources/colors_object.xml",

		dataType: "xml",
		xmlElementName: "color",

		getValue: function(element) {
			return $(element).find("name").text();
		},

		template: {
			type: "links",
			fields: {
				link: function(element) {
					return "http://site." + $(element).find("name").text();
				}
			}
		},

		list: {
			match: {
				enabled: false
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
	$("#inputOne").val("z").trigger(e);

	
	QUnit.stop();
	
	//assert
	function assertList() {
		var elements = $("#inputOne").next().find("ul li");

		assert.ok($("#inputOne").parent().hasClass("undefined") === false, "There is no class undefined");

		assert.equal(4, elements.length, "Response size");
		assert.equal("<a href=\"http://site.red\">red</a>", elements.eq(0).find("div").html(), "First element value");
		assert.equal("<a href=\"http://site.green\">green</a>", elements.eq(1).find("div").html(), "Second element value");

		QUnit.start();
	}
});


QUnit.test("Template - custom", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		data: [{country: "Poland", site: "pl"}, {country: "Germany", site: "de"}, {country: "Italy", site: "it"}],

		getValue: "country",

		template: {
			type: "custom",
			method: function(value, item) {
				return "<p>" + value + "</p><b>" + item.site + "</b>";
			}
		},

		list: {
			match: {
				enabled: false
			}
		}

	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("z").trigger(e);

	
	//assert

	var elements = $("#inputOne").next().find("ul li");

	assert.ok($("#inputOne").parent().hasClass("undefined") === false, "There is no class undefined");

	assert.equal(3, elements.length, "Response size");
	assert.equal("<p>Poland</p><b>pl</b>", elements.eq(0).find("div").html(), "First element value");
	assert.equal("<p>Germany</p><b>de</b>", elements.eq(1).find("div").html(), "Second element value");
	
});


QUnit.test("Template - custom - xml provider", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		url: "resources/colors.xml",

		dataType: "xml",
		xmlElementName: "color",

		template: {
			type: "custom",
			method: function(value, item) {
				return "<p>" + value + "</p>";
			}
		},

		list: {
			match: {
				enabled: false
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
	$("#inputOne").val("z").trigger(e);

	QUnit.stop();
	
	//assert
	function assertList() {
		var elements = $("#inputOne").next().find("ul li");

		assert.ok($("#inputOne").parent().hasClass("undefined") === false, "There is no class undefined");

		assert.equal(4, elements.length, "Response size");
		assert.equal("<p>red</p>", elements.eq(0).find("div").html(), "First element value");
		assert.equal("<p>green</p>", elements.eq(1).find("div").html(), "Second element value");

		QUnit.start();
	}
});


QUnit.test("Template - custom - xml provider - complex data", function( assert ) {
	expect(4);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {

		url: "resources/colors_object.xml",

		dataType: "xml",
		xmlElementName: "color",

		getValue: function(element) {
			return $(element).find("name").text();
		},

		template: {
			type: "custom",
			method: function(value, item) {
				return "<p>" + value + "</p>" + "<b>" + $(item).find("name").text() +"</b>";
			}
		},

		list: {
			match: {
				enabled: false
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
	$("#inputOne").val("z").trigger(e);

	
	QUnit.stop();
	
	//assert
	function assertList() {
		var elements = $("#inputOne").next().find("ul li");

		assert.ok($("#inputOne").parent().hasClass("undefined") === false, "There is no class undefined");

		assert.equal(4, elements.length, "Response size");
		assert.equal("<p>red</p><b>red</b>", elements.eq(0).find("div").html(), "First element value");
		assert.equal("<p>green</p><b>green</b>", elements.eq(1).find("div").html(), "Second element value");

		QUnit.start();
	}
});

