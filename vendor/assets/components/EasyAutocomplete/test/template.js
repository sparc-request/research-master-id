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
 * Tests for Template module - EasyAutocomplete 
 *
 * @author Łukasz Pawełczak
 */

QUnit.test("Template - module", function( assert ) {

	//execute
	var Template = new EasyAutocomplete.Template();


	//assert
	assert.ok(typeof EasyAutocomplete.Template === "function", "Constructor found");
	assert.ok(Template, "Constructor");
	assert.ok(typeof Template === "object", "created object");
	assert.ok(typeof Template.build === "function", "Template has method build");
	assert.ok(Template.getTemplateClass() === '', "css class");
});


QUnit.test("Template - default template", function( assert ) {

	//given
	var options = {};


	//execute
	var Template = new EasyAutocomplete.Template(options);

	//assert
	assert.ok(typeof Template.build == "function", "Build is function");
	assert.ok(Template.build("suggestion") === "suggestion", "Build returns value");	
	assert.ok(Template.build.toString() === 'function (element) { return element; }', "Build equals def value");
	
	expect(3);
});


QUnit.test("Template - description template - field string", function( assert ) {
	

	//given
	var	options = {type: "description", fields: {description: "description"}};


	//execute
	var template = new EasyAutocomplete.Template(options);
		

	//assert
	assert.ok(typeof template.build == "function", "Build is function");
	assert.ok(template.build("bruce", {description: "willis"}) === "bruce - <span>willis</span>", "Build returns value");
	assert.ok(template.getTemplateClass() === 'eac-description', "css class");	
	//assert.ok(template.build.toString() === 'function (element) {	return element + " - description"; }', "Build equals def value");
	expect(3);
});

QUnit.test("Template - description template - field function", function( assert ) {
	

	//given
	var	options = {type: "description", fields: {description: function(element) {return element["description"];}}};


	//execute
	var template = new EasyAutocomplete.Template(options);
		

	//assert
	assert.ok(typeof template.build == "function", "Build is function");
	assert.ok(template.build("bruce", {description: "willis"}) === "bruce - <span>willis</span>", "Build returns value");
	assert.ok(template.getTemplateClass() === 'eac-description', "css class");	

	expect(3);
});

QUnit.test("Template - iconLeft template - field string", function( assert ) {
	

	//given
	var	options = {type: "iconLeft", fields: {iconSrc: "iconSrc"}};


	//execute
	var template = new EasyAutocomplete.Template(options);


	//assert
	assert.ok(typeof template.build == "function", "Build is function");
	assert.ok(template.build("Brad Pitt", {iconSrc: "http://easyautocomplete.com/icon/pitt.jpg"}) === "<img class='eac-icon' src='http://easyautocomplete.com/icon/pitt.jpg' />Brad Pitt", "Build returns value");	
	assert.ok(template.getTemplateClass() === 'eac-icon-left', "css class");
	expect(3);
});

QUnit.test("Template - iconLeft template - field function", function( assert ) {
	

	//given
	var	options = {type: "iconLeft", fields: {iconSrc: function(element) {return element["iconSrc"];}}};


	//execute
	var template = new EasyAutocomplete.Template(options);


	//assert
	assert.ok(typeof template.build == "function", "Build is function");
	assert.ok(template.build("Brad Pitt", {iconSrc: "http://easyautocomplete.com/icon/pitt.jpg"}) === "<img class='eac-icon' src='http://easyautocomplete.com/icon/pitt.jpg' />Brad Pitt", "Build returns value");	
	assert.ok(template.getTemplateClass() === 'eac-icon-left', "css class");
	expect(3);
});

QUnit.test("Template - iconRight template - field string", function( assert ) {
	

	//given
	var	options = {type: "iconRight", fields: {iconSrc: "iconSrc"}};


	//execute
	var template = new EasyAutocomplete.Template(options);


	//assert
	assert.ok(typeof template.build == "function", "Build is function");
	assert.ok(template.build("Matt", {iconSrc: "http://Damon.com"}) === "Matt<img class='eac-icon' src='http://Damon.com' />", "Build returns value");	
	assert.ok(template.getTemplateClass() === 'eac-icon-right', "css class");
	expect(3);
});

QUnit.test("Template - iconRight template - field function", function( assert ) {
	

	//given
	var	options = {type: "iconRight", fields: {iconSrc: function(element) {return element["iconSrc"];}}};


	//execute
	var template = new EasyAutocomplete.Template(options);


	//assert
	assert.ok(typeof template.build == "function", "Build is function");
	assert.ok(template.build("Matt", {iconSrc: "http://Damon.com"}) === "Matt<img class='eac-icon' src='http://Damon.com' />", "Build returns value");	
	assert.ok(template.getTemplateClass() === 'eac-icon-right', "css class");
	expect(3);
});

QUnit.test("Template - links template - field string", function( assert ) {
	

	//given
	var	options = {type: "links", fields: {link: "website_link"}};


	//execute
	var template = new EasyAutocomplete.Template(options);


	//assert
	assert.ok(typeof template.build == "function", "Build is function");
	assert.ok(template.build("EasyAutocomplete website", {website_link: "http://easyautocomplete.com"}) === "<a href='http://easyautocomplete.com' >EasyAutocomplete website</a>", "Build returns value");	
	assert.ok(template.getTemplateClass() === '', "css class");
	expect(3);
});


QUnit.test("Template - links template - field function", function( assert ) {
	

	//given
	var	options = {type: "links", fields: {link: function(element) {return element["website_link"];} }};


	//execute
	var template = new EasyAutocomplete.Template(options);


	//assert
	assert.ok(typeof template.build == "function", "Build is function");
	assert.ok(template.build("EasyAutocomplete website", {website_link: "http://easyautocomplete.com"}) === "<a href='http://easyautocomplete.com' >EasyAutocomplete website</a>", "Build returns value");	
	assert.ok(template.getTemplateClass() === '', "css class");
	expect(3);
});


QUnit.test("Template - custom template", function( assert ) {
	

	//given
	var	options = {type: "custom", method: function() {}};


	//execute
	var template = new EasyAutocomplete.Template(options);
				

	//assert
	assert.ok(typeof template.build === "function", "Build is function");
	assert.ok(template.build.toString() === 'function () {}', "Build equals def value");
	assert.ok(template.getTemplateClass() === '', "css class");
	expect(3);
});


QUnit.test("Template - cssClass description", function( assert ) {
	

	//given
	var	options = {type: "description", fields: {description: "description"}, method: function() {}};


	//execute
	var template = new EasyAutocomplete.Template(options);
				
	//assert
	assert.ok(typeof template.getTemplateClass === "function", "Build is function");
	assert.ok(template.getTemplateClass() === 'eac-description', "Build equals def value");
	expect(2);
});


