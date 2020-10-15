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
 * Tests EasyAutocomplete - event
 *
 * @author Łukasz Pawełczak
 */

 /*
QUnit.test("Event keypress - Esc keyCode", function( assert ) {
	expect(1);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {url: "resources/colors_string.json", ajaxCallback: function() {

	
			var e = $.Event("keyup", { keyCode: 27 });
			$("inputOne").trigger(e);
	

			//assert
			assertList();
		}
	});


	//execute
	
	completerOne.init();

	var e = $.Event('keyup');
	e.keyCode = 50; 
	$("#inputOne").val("c").trigger(e);

	//create event with Esc keyCode



	QUnit.stop();


	//assert

	function assertList() {
		var elements = $("#inputOne").next().find("ul li");

		assert.equal(3, elements.length, "Response size");
		//assert.equal("none", $("#eac-container-inputOne").find("ul").css("display"), "List should be hidden");

		QUnit.start();	
	}
});
*/

QUnit.test("Event onLoadEvent ", function( assert ) {
	expect(1);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {url: "resources/colors_string.json",


		list: {
			onLoadEvent: function() {

				//assert
				assertList();
			}
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

		QUnit.start();	
	}
});




QUnit.test("Event onClickEvent ", function( assert ) {
	expect(1);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {url: "resources/colors_string.json",


		list: {
			onClickEvent: function() {

				//assert
				assertList();
			},
			onLoadEvent: function() {

				//trigger click event
				$("#inputOne").next().find("ul li").eq(0).find(" > div").trigger("click");
			}
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

		QUnit.start();	
	}
});

QUnit.test("Event onMouseOverEvent ", function( assert ) {
	expect(1);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {url: "resources/colors_string.json",

		list: {
			onMouseOverEvent: function() {

				//assert
				assertList();
			},
			onLoadEvent: function() {

				//trigger click event
				$("#inputOne").next().find("ul li").eq(0).find(" > div").trigger("mouseover");
			}
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

		QUnit.start();	
	}
});


QUnit.test("Event onMouseOutEvent ", function( assert ) {
	expect(1);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {url: "resources/colors_string.json",

			list: {
				onMouseOutEvent: function() {

					//assert
					assertList();
				},
				onLoadEvent: function() {

					//trigger click event
					$("#inputOne").next().find("ul li").eq(0).find(" > div").trigger("mouseout");
				}	
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

		QUnit.start();	
	}
});

QUnit.test("Event onSelectItemEvent ", function( assert ) {
	expect(1);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {url: "resources/colors_string.json",

			list: {
				onSelectItemEvent: function() {

					//assert
					assertList();
				},
				onLoadEvent: function() {

					//trigger select event
					var key = $.Event('keyup');
					key.keyCode = 40; 
					$input.trigger(key);
				}	
			}
			
	}),
	$input = $("#inputOne");


	//execute
	completerOne.init();
	var e = $.Event('keyup');
	e.keyCode = 50; 
	$input.val("c").trigger(e);

	QUnit.stop();

	//assert

	function assertList() {

		var elements = $("#inputOne").next().find("ul li");

		assert.equal(3, elements.length, "Response size");

		QUnit.start();	
	}
});

QUnit.test("Event onSelectItemEvent should trigger when user writes phrase that matches phrase from suggestion list and then focus out of the input field", function( assert ) {
	expect(1);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {url: "resources/colors_string.json",

			list: {
				onSelectItemEvent: function() {

					//assert
					assertList();
				},
				onLoadEvent: function() {

					$input.trigger("focusout");				
				}	
			}
			
	}),
	$input = $("#inputOne");


	//execute
	completerOne.init();
	var e = $.Event('keyup');
	e.keyCode = 50; 
	$input.val("red").trigger(e);
	

	QUnit.stop();

	//assert

	function assertList() {

		var elements = $("#inputOne").next().find("ul li");

		assert.equal(3, elements.length, "Response size");

		QUnit.start();	
	}
});

QUnit.test("Event onSelectItemEvent should trigger when user writes phrase that matches phrase from suggestion list and then focus out of the input field - include case sensitivity", function( assert ) {
    expect(1);

    //given
    var completerOne = new EasyAutocomplete.main($("#inputOne"), {url: "resources/colors_string.json",

            list: {
                onSelectItemEvent: function() {

                    //assert
                    assertList();
                },
                onLoadEvent: function() {

                    $input.trigger("focusout");
                }
            }

        }),
        $input = $("#inputOne");


    //execute
    completerOne.init();
    var e = $.Event('keyup');
    e.keyCode = 50;
    $input.val("ReD").trigger(e);


    QUnit.stop();

    //assert

    function assertList() {

        var elements = $("#inputOne").next().find("ul li");

        assert.equal(3, elements.length, "Response size");

        QUnit.start();
    }
});

QUnit.test("Event onSelectItemEvent should trigger when user writes phrase that matches phrase from suggestion list and then focus out of the input field - include case sensitivity false", function( assert ) {
    expect(1);

    //given
    var completerOne = new EasyAutocomplete.main($("#inputOne"), {url: "resources/colors_caps_string.json",

            list: {
                onSelectItemEvent: function() {

                    //assert
                    assertList();
                },
                onLoadEvent: function() {

                    $input.trigger("focusout");
                },
                match: {
                    caseSensitive: false,
                    enabled: true
                }
            }

        }),
        $input = $("#inputOne");


    //execute
    completerOne.init();
    var e = $.Event('keyup');
    e.keyCode = 50;
    $input.val("red").trigger(e);


    QUnit.stop();

    //assert

    function assertList() {

        var elements = $("#inputOne").next().find("ul li");

        assert.equal(1, elements.length, "Response size");

        QUnit.start();
    }
});

QUnit.test("Event onSelectItemEvent should trigger when user writes phrase that matches phrase from suggestion list and then focus out of the input field - include case sensitivity true", function( assert ) {
    expect(1);

    //given
    var completerOne = new EasyAutocomplete.main($("#inputOne"), {url: "resources/colors_caps_string.json",

            list: {
                onSelectItemEvent: function() {

                },
                onLoadEvent: function() {

                    $input.trigger("focusout");

                    QUnit.start();
                },
                match: {
                    caseSensitive: true,
                    enabled: true
                }
            }

        }),
        $input = $("#inputOne");


    //execute
    completerOne.init();
    var e = $.Event('keyup');
    e.keyCode = 50;
    $input.val("red").trigger(e);


    QUnit.stop();

    //assert
    var elements = $("#inputOne").next().find("ul li");

    assert.equal(0, elements.length, "Response size");

});

QUnit.test("Event onShowListEvent ", function( assert ) {
	expect(1);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {url: "resources/colors_string.json",

			list: {
				onShowListEvent: function() {

					//assert
					assertList();
				}
			}
			
	}),
	$input = $("#inputOne");


	//execute
	completerOne.init();
	var e = $.Event('keyup');
	e.keyCode = 50; 
	$input.val("c").trigger(e); //trigger show list

	QUnit.stop();

	//assert

	function assertList() {

		var elements = $("#inputOne").next().find("ul li");

		assert.equal(3, elements.length, "Response size");

		QUnit.start();	
	}
});

QUnit.test("Event onHideListEvent ", function( assert ) {
	expect(1);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {url: "resources/colors_string.json",

			list: {
				onHideListEvent: function() {

					//assert
					assertList();
				},
				onLoadEvent: function() {

					//trigger hide list
					var key = $.Event('keyup');
					key.keyCode = 27; 
					$input.trigger(key);
				}	
			}
			
	}),
	$input = $("#inputOne");


	//execute
	completerOne.init();
	var e = $.Event('keyup');
	e.keyCode = 50; 
	$input.val("c").trigger(e);

	QUnit.stop();

	//assert

	function assertList() {

		var elements = $("#inputOne").next().find("ul li");

		assert.equal(3, elements.length, "Response size");

		QUnit.start();	
	}
});

QUnit.test("Event onKeyEnterEvent ", function( assert ) {
	expect(1);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {url: "resources/colors_string.json",

			list: {
				onKeyEnterEvent: function() {

					//assert
					assertList();
				},
				onLoadEvent: function() {


					//trigger select event
					var key = $.Event('keyup');
					key.keyCode = 40; 
					$input.trigger(key);


					//trigger key enter
					var key = $.Event('keydown');
					key.keyCode = 13; 
					$input.trigger(key);
				}	
			}
			
	}),
	$input = $("#inputOne");


	//execute
	completerOne.init();
	var e = $.Event('keyup');
	e.keyCode = 50; 
	$input.val("c").trigger(e);

	QUnit.stop();

	//assert

	function assertList() {

		var elements = $("#inputOne").next().find("ul li");

		assert.equal(3, elements.length, "Response size");

		QUnit.start();	
	}
});


QUnit.test("Event onClickEvent and selectedItemData - click", function( assert ) {
	expect(2);
	
	//given
	var $input = $("#inputOne");

	$input.easyAutocomplete({

			url: "resources/colors_string.json",

			list: {
				onClickEvent: function() {

					//assert
					assertList();
				},
				onLoadEvent: function() {


					//trigger click event
					$("#inputOne").next().find("ul li").eq(0).find(" > div").trigger("click");
				}	
			}
			
	});
	


	//execute
	
	var e = $.Event('keyup');
	e.keyCode = 50; 
	$input.val("c").trigger(e);

	QUnit.stop();

	//assert

	function assertList() {

		var elements = $input.next().find("ul li"),
			data = $input.getSelectedItemData();

		assert.equal(3, elements.length, "Response size");
		assert.equal("red", data, "selectedItemData matches");

		QUnit.start();	
	}
});

QUnit.test("Event onKeyEnterEvent and selectedItemData - keydown enter", function( assert ) {
	expect(2);
	
	//given
	var $input = $("#inputOne");

	$input.easyAutocomplete({

			url: "resources/colors_string.json",

			list: {
				onKeyEnterEvent: function() {

					//assert
					assertList();
				},
				onLoadEvent: function() {

					//trigger select event
					var key = $.Event('keyup');
					key.keyCode = 40; 
					$input.trigger(key);


					//trigger key enter
					var key = $.Event('keydown');
					key.keyCode = 13; 
					$input.trigger(key);
				}	
			}
			
	});
	


	//execute
	
	var e = $.Event('keyup');
	e.keyCode = 50; 
	$input.val("c").trigger(e);

	QUnit.stop();

	//assert

	function assertList() {

		var elements = $input.next().find("ul li"),
			data = $input.getSelectedItemData();

		assert.equal(3, elements.length, "Response size");
		assert.equal("red", data, "selectedItemData matches");


		QUnit.start();	
	}
});


QUnit.test("Plugin should not emit event 'show' ", function( assert ) {
	expect(1);
	
	//given
	var $input = $("#inputOne"),
		eventReceived = false;


	$("body")
	.on("show", function() {
		eventReceived = true;
	})
	.on("show.eac", function() {

		//assert
		assertList();

		QUnit.start();	

		afterTests();
	});

	

	$input.easyAutocomplete({
		url: "resources/colors_string.json",			
	});
	


	//execute
	
	var e = $.Event('keyup');
	e.keyCode = 50; 
	$input.val("c").trigger(e); //trigger show list

	QUnit.stop();

	//assert

	function assertList() {

		assert.ok(eventReceived === false, "Event received");
	}

	function afterTests() {

		$("body").off("show").off("show.eac");
	}

});

QUnit.test("Plugin should not emit event 'hide' ", function( assert ) {
	expect(1);
	
	//given
	var $input = $("#inputOne"),
		eventReceived = false;


	$("body")
	.on("hide", function() {
		eventReceived = true;
	})
	.on("hide.eac", function() {

		//assert
		assertList();

		QUnit.start();	
		
		afterTests();
	});

	

	$input.easyAutocomplete({
		url: "resources/colors_string.json",	

		list: {
			onLoadEvent: function() {

				//trigger hide list
				var key = $.Event('keyup');
				key.keyCode = 27; 
				$input.trigger(key);
			}	
		}		
	});
	


	//execute
	
	var e = $.Event('keyup');
	e.keyCode = 50; 
	$input.val("c").trigger(e); //trigger show list

	QUnit.stop();

	//assert

	function assertList() {

		assert.ok(eventReceived === false, "Event received");
	}

	function afterTests() {

		$("body").off("hide").off("hide.eac");
	}

});


QUnit.test("Plugin should not emit event 'selectElement' ", function( assert ) {
	expect(1);
	
	//given
	var $input = $("#inputOne"),
		eventReceived = false;


	$("body")
	.on("selectElement", function() {
		eventReceived = true;
	})
	.on("selectElement.eac", function() {

		//assert
		assertList();

		QUnit.start();	
		
		afterTests();
	});

	

	$input.easyAutocomplete({
		url: "resources/colors_string.json",	

		list: {
			onLoadEvent: function() {

				//trigger select event
				var key = $.Event('keyup');
				key.keyCode = 40; 
				$input.trigger(key);
			}	
		}		
	});
	


	//execute
	
	var e = $.Event('keyup');
	e.keyCode = 50; 
	$input.val("c").trigger(e); //trigger show list

	QUnit.stop();

	//assert

	function assertList() {

		assert.ok(eventReceived === false, "Event received");
	}

	function afterTests() {

		$("body").off("selectElement").off("selectElement.eac");
	}

});


QUnit.test("Plugin should not emit event 'loadElements' ", function( assert ) {
	expect(1);
	
	//given
	var $input = $("#inputOne"),
		eventReceived = false;


	$("body")
	.on("loadElements", function() {
		eventReceived = true;
	})
	.on("loadElements.eac", function() {

		//assert
		assertList();

		QUnit.start();	
		
		afterTests();
	});

	

	$input.easyAutocomplete({
		url: "resources/colors_string.json",	
	});
	


	//execute
	
	var e = $.Event('keyup');
	e.keyCode = 50; 
	$input.val("c").trigger(e); //trigger show list

	QUnit.stop();

	//assert

	function assertList() {

		assert.ok(eventReceived === false, "Event received");
	}

	function afterTests() {

		$("body").off("loadElements").off("loadElements.eac");
	}

});


QUnit.test("Event onChooseEvent - key enter", function( assert ) {
	expect(1);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {url: "resources/colors_string.json",

			list: {
				onChooseEvent: function() {

					//assert
					assertList();
				},
				onLoadEvent: function() {


					//trigger select event
					var key = $.Event('keyup');
					key.keyCode = 40; 
					$input.trigger(key);


					//trigger key enter
					var key = $.Event('keydown');
					key.keyCode = 13; 
					$input.trigger(key);
				}	
			}
			
	}),
	$input = $("#inputOne");


	//execute
	completerOne.init();
	var e = $.Event('keyup');
	e.keyCode = 50; 
	$input.val("c").trigger(e);

	QUnit.stop();

	//assert

	function assertList() {

		var elements = $("#inputOne").next().find("ul li");

		assert.equal(3, elements.length, "Response size");

		QUnit.start();	
	}
});

QUnit.test("Event onChooseEvent - click", function( assert ) {
	expect(1);
	
	//given
	var completerOne = new EasyAutocomplete.main($("#inputOne"), {url: "resources/colors_string.json",

			list: {
				onChooseEvent: function() {

					//assert
					assertList();
				},
				onLoadEvent: function() {


					//trigger click event
					$("#inputOne").next().find("ul li").eq(0).find(" > div").trigger("click");
				}	
			}
			
	}),
	$input = $("#inputOne");


	//execute
	completerOne.init();
	var e = $.Event('keyup');
	e.keyCode = 50; 
	$input.val("c").trigger(e);

	QUnit.stop();

	//assert

	function assertList() {

		var elements = $("#inputOne").next().find("ul li");

		assert.equal(3, elements.length, "Response size");

		QUnit.start();	
	}
});

