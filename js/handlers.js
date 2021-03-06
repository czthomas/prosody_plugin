/*globals
    WPURLS
*/
/*jshint browser: true, jquery: true, devel: true */
/*jshint esversion: 6 */
// URLS for use throughout file

var $ = jQuery;

var siteUrl = WPURLS.siteurl;
var correctAnswerUrl = siteUrl + "/wp-content/plugins/prosody_plugin/images/correct.png";
var incorrectAnswerUrl = siteUrl + "/wp-content/plugins/prosody_plugin/images/incorrect.png";
var expectedAnswerUrl = siteUrl + "/wp-content/plugins/prosody_plugin/images/expected.png";
// This is a hack. We're using it to shave off a pixel to get the shadowsyllables to correctly sit on top of the real syllables.
var STRESS_WIDTH = 1;

/* This is the array that will hold the correction state of line features */
var lineStates = [];

var docSource = 'prosody';
var docStyle = 'poetry';

// Test flag to enable correction for unplaced marks
var FULL_CORRECTION = false;

var setLineFeatureState = function(lineNumber, feature, state) {
    if (lineStates && lineStates[lineNumber - 1]) {
        lineStates[lineNumber - 1][feature] = state;
        if (state === true) { // check if Note needs to be shown
            showNote(lineNumber);
        }
    } else {
        console.error('Cannot read state for Line ' + (lineNumber - 1) + '.');
    }
};

var getLineFeatureState = function(lineNumber, feature) {
    if (lineStates && lineStates[lineNumber - 1]) {
        if (undefined !== lineStates[lineNumber - 1][feature]) {
            return lineStates[lineNumber - 1][feature];
        } else {
            setLineFeatureState(lineNumber, feature, false);
            return false;
        }
    } else {
        console.error('Cannot read state for Line ' + (lineNumber - 1) + '.');
        return false;
    }
};
function checkrhyme(scheme, answer) {
    if (scheme === answer) {
        $('#rhymecheck').addClass('right');
        $('#rhymecheck').removeClass('wrong');
        $('#rhymecheck').val('\u2713');
    } else {
        $('#rhymecheck').addClass('wrong');
        $('#rhymecheck').removeClass('right');
        $('#rhymecheck').val('X');
    }
}

function checkmeter(lineNumber, lineGroupIndex) {
    var fullAnswer = $('#prosody-real-' + lineNumber + " span[answer]").attr('answer');
    if (!fullAnswer) {
        console.log("There is no answer given for this line.");
    }
    var footType = fullAnswer.split('(')[0];
    var numberFeet = fullAnswer.match(/\d+/g)[lineGroupIndex - 1];
    var correctAnswer = footType + numberFeet;

    $('#check-answer').one("click", function() {
        var feature = 'meter';
        var meterCorrect = getLineFeatureState(lineNumber, feature);
        var footScheme = $('#foot-select').val();
        var numberScheme = $('#number-select').val();
        var fullScheme = footScheme + numberScheme;

        var dolnik = (footScheme == '+++' || footScheme == '++++');
        if (correctAnswer === fullScheme || (dolnik && footScheme == footType)) {
            $('#checkmeter' + lineNumber + " img").attr("src", correctAnswerUrl);
            meterCorrect = true;
        } else {
            $('#checkmeter' + lineNumber + " img").attr("src", incorrectAnswerUrl);
            meterCorrect = false;
        }

        $('#meter-select').dialog("close");
        showSyncopation();
        setLineFeatureState(lineNumber, feature, meterCorrect);
    });

    $('#meter-select').dialog("open");
}

function switchstress(shadowSyllable) {
    var realSyllable = $('#prosody-real-' + shadowSyllable.id.substring(15));
    var stress = realSyllable.attr('data-stress');

    if (stress === '-' || !stress) {
        $('#' + shadowSyllable.id).fadeIn();
        $('#' + shadowSyllable.id).children(':not(.stress-spacer)').remove();
        $('#' + shadowSyllable.id).append(marker(realSyllable));
        realSyllable.attr('data-stress', '+');
    } else {
        $('#' + shadowSyllable.id).fadeOut();
        setTimeout(function() {
            $('#' + shadowSyllable.id).children(':not(.stress-spacer)').remove();
            $('#' + shadowSyllable.id).append(placeholder(realSyllable));
            realSyllable.attr('data-stress', '-');
        }, 150);
        $('#' + shadowSyllable.id).fadeIn();
    }

    var digits = /\d+/;
    var sub = digits.exec(shadowSyllable.id);
    var shadowLineNumber = '';
    if (sub !== null) {
        shadowLineNumber = sub[0];
    }

    $('#checkstress' + shadowLineNumber + ' img').attr('src', siteUrl + '/wp-content/plugins/prosody_plugin/images/stress-default.png');

    $(shadowSyllable).removeClass('prosody-correct')
        .removeClass('prosody-incorrect')
        .removeClass('prosody-expected');
    
    $(realSyllable).removeClass('prosody-correct')
        .removeClass('prosody-incorrect')
        .removeClass('prosody-expected');
}

function checkstress(lineNumber) {
    var feature = 'stress';
    var stressCorrect = getLineFeatureState(lineNumber, feature);
    // Scheme is the user submitted stress marks
    var scheme = '';
    $('#prosody-real-' + lineNumber + ' .prosody-syllable').each(
        function() {
            var syllableStress = this.dataset.stress;
            scheme += syllableStress ? syllableStress : '-';
        }
    );

    // Make sure the answer is complete
    var answerLength = $('#prosody-real-' + lineNumber + ' .prosody-syllable').length;
    var schemeLength = scheme.length;

    if (answerLength !== schemeLength) {
        alert("An answer must be complete to be submitted. Please fill in a symbol over each syllable in this line.");
        setLineFeatureState(lineNumber, feature, false);
        return;
    }

    var realAnswer = '', expectedAnswer = '';
    if(docSource == 'rhythm') {
        $('#prosody-real-' + lineNumber + ' .prosody-syllable').each(
            function() {
                realAnswer += this.dataset.real;
            }
        );
    } else {
        var answer = $('#prosody-real-' + lineNumber).data('real').split('|');
        realAnswer = answer[0];
        // Remove the parentheses that some poems have for optional stress marks
        realAnswer = realAnswer.replace(/\(|\)/g, '');
        expectedAnswer;
        // if answer[1] exists, and answer[1] does not equal answer[0]
        if (answer[1] && answer[1] !== answer[0]) {
            expectedAnswer = answer[1];
        }
    }

    if (scheme === realAnswer) {
        $("#checkstress" + lineNumber + " img").attr("src", correctAnswerUrl);
        stressCorrect = true;
        // showNote(lineNumber);
    } else if (scheme === expectedAnswer) {
        $("#checkstress" + lineNumber + " img").attr("src", expectedAnswerUrl);
        stressCorrect = true;
        // showNote(lineNumber);
    } else {
        $("#checkstress" + lineNumber + " img").attr("src", incorrectAnswerUrl);
        stressCorrect = false;
    }

    correctStress(lineNumber, scheme, realAnswer, expectedAnswer);

    setLineFeatureState(lineNumber, feature, stressCorrect);
    showSyncopation();

}

function verifyShowNote(lineNumber) {
    var criteria = ['stress', 'meter', 'feet'];
    var verified = criteria.filter((feature) => lineStates[lineNumber - 1][feature]); // filter out the features that are not set to "true"
    return criteria.length === verified.length;
}

function showNote(lineNumber) {
    if (verifyShowNote(lineNumber)) {
        $("#displaynotebutton" + lineNumber).show().click(function() {
            $('#hintfor' + lineNumber).hide();
            togglenote(lineNumber);
        });
    }
}

function correctStress(lineNumber, response, correct, expected) {
    var shadowLine = $('#prosody-shadow-' + lineNumber + ' > .prosody-shadowsyllable');

    for(var idx = 0; idx < response.length; idx++) {
        $(shadowLine[idx]).removeClass('prosody-correct')
            .removeClass('prosody-incorrect')
            .removeClass('prosody-expected');

        var realSyllable = $('#prosody-real-' + shadowLine[idx].id.substring(15));
        $(realSyllable).removeClass('prosody-correct')
            .removeClass('prosody-incorrect')
            .removeClass('prosody-expected');

        if(response.charAt(idx) != '-') {
            if(response.charAt(idx) == correct.charAt(idx)) {
                $(shadowLine[idx]).addClass('prosody-correct');
                $(realSyllable).addClass('prosody-correct');
            } else if(expected && response.charAt(idx) == expected.charAt(idx)) {
                $(shadowLine[idx]).addClass('prosody-expected');
                $(realSyllable).addClass('prosody-expected');
            } else {
                $(shadowLine[idx]).addClass('prosody-incorrect');
                $(realSyllable).addClass('prosody-incorrect');
            }
        } else {
            if(FULL_CORRECTION && correct.charAt(idx) == '+') {
                switchstress(shadowLine[idx]);
            }
        }
    }
}

function correctFeet(lineNumber, response, correct) {
    var reals = $('#prosody-real-' + lineNumber + ' .prosody-syllable');
    var feet = correct.split('|');

    // walk syllables down foot-graph to locate and correct footmarkers
    var realIdx = 0;
    for(var footIdx = 0; footIdx < feet.length; footIdx++) {
        var target = feet[footIdx];
        for(; realIdx < reals.length; realIdx++) {
            var raw = normalizeText(reals[realIdx].dataset['raw']);
            var searchIdx = target.search(raw);
            
            target = target.substr(searchIdx + raw.length);

            if(/\|/.test(reals[realIdx].innerText)) {
                var markers = $(reals[realIdx]).children('.prosody-footmarker');

                if(target.length == 0) {
                    markers.addClass('prosody-correct');
                } else {
                    markers.addClass('prosody-incorrect');
                }
            }
            
            if(searchIdx == -1) break;
            else if(FULL_CORRECTION && target.length == 0 && $(reals[realIdx]).children().length == 0) {
                switchfoot(reals[realIdx].id);
            }
        }
    }
}

function showSyncopation() {
    var corrects = $('img[src$="images/correct.png"]');
    var expecteds = $('img[src$="images/expected.png"]');
    var totalCorrect = corrects.length + expecteds.length;
    var numLines = $('.prosody-line');
    if (totalCorrect === numLines.length * 3) {
        $('#syncopation').show();
    } else if (totalCorrect !== numLines.length) {
        $('#syncopation').hide();
    }
}

function switchfoot(event, syllableId) {
    if(docStyle == 'prose') return;

    var syllableSpan = $('#' + syllableId + ' span');
    if (syllableSpan.length === 0) {
        $('#' + syllableId).append('<span class="prosody-footmarker">|</span>');
        syllableSpan = $('#' + syllableId + ' span');
    } else {
        $('#' + syllableId + ' .prosody-footmarker').remove();
    }

    var digit_search = /\d+/;
    var digit_group = digit_search.exec(syllableId);
    var shadowLineNumberSection = '';
    if (digit_group !== null) {
        shadowLineNumberSection = digit_group[0];
    }

    $("#checkfeet" + shadowLineNumberSection + " img").attr("src", siteUrl + "/wp-content/plugins/prosody_plugin/images/feet-default.png");

    var footSyllable = $('#' + syllableId);
    var footSyllableWidth = footSyllable.width();
    var footSyllableId = footSyllable.attr('id').substring(13);
    var footShadowSyllable = $('#prosody-shadow-' + footSyllableId);
    setTimeout(function() {
        footShadowSyllable.width(footSyllableWidth - STRESS_WIDTH);
    }, 100);
}

// strips whitespace and punctuation (except for pipe), relatively unicode safe
function normalizeText(input) {
    return input.replace(
        // latin block punctuation, unicode general and supplemental punctuation blocks
        /[-\s!"#$%&'()*+,./:;<=>?@[\]^_`{}~\u00a1-\u00bf\u2000-\u206f\u2e00-\u2e7f]/gu,
        '');
}

function checkfeet(lineNumber) {
    var feature = 'feet';
    var feetCorrect = getLineFeatureState(lineNumber, feature);
    var scheme = $('#prosody-real-' + lineNumber + ' span[real]').text();
    var answer = $('#prosody-real-' + lineNumber).data('feet');
    if (scheme.endsWith('|')) {
        scheme = scheme.slice(0, -1);
    }

    var answer = normalizeText(answer);
    var scheme = normalizeText(scheme);

    if (scheme === answer) {
        $("#checkfeet" + lineNumber + " img").attr("src", correctAnswerUrl);
        feetCorrect = true;
        $("#prosody-real-" + lineNumber + " .prosody-footmarker").addClass('prosody-correct');
    } else {
        $("#checkfeet" + lineNumber + " img").attr("src", incorrectAnswerUrl);
        feetCorrect = false;
        correctFeet(lineNumber, scheme, answer);
    }
    setLineFeatureState(lineNumber, feature, feetCorrect);

    showSyncopation();
}

function togglenote(lineNumber) {
    if ($('#hintfor' + lineNumber).css('display') === 'none') {
        $('#hintfor' + lineNumber).dialog();
        $('#hintfor' + lineNumber).show();
    } else {
        $('#hintfor' + lineNumber).dialog('close');
        $('#hintfor' + lineNumber).hide();
    }
}

function togglestress(node) {
    $('.prosody-marker').each(function(i, el) {
        if (node.checked) {
            $(el).show();
        } else {
            $(el).hide();
        }
    });

}

function togglefeet(node) {
    $('.prosody-footmarker').each(function(i, el) {
        if (node.checked) {
            $(el).show();
        } else {
            $(el).hide();
        }
    });
}

function togglecaesura(node) {
    $('.caesura').each(function(i, el) {
        if (node.checked) {
            $(el).show();
        } else {
            $(el).hide();
        }
    });
}

function toggledifferences(node) {
    if (node.checked) {
        $('span[discrepant]').addClass('discrep');
    } else {
        $('span[discrepant]').removeClass('discrep');
    }
}

function addMarker(real, symbol) {
    var prosodyMarker = document.createElement("span");
    prosodyMarker.className = docSource + "-marker";

    prosodyMarker.textContent = symbol;
    return prosodyMarker;
}

function marker(real) {
    return addMarker(real, "/");
}

function slackmarker(real) {
    return addMarker(real, "\u222A");
}

function placeholder(real) {
    return addMarker(real, " ");
}

function decodeEntities(encodedString) {
    var textArea = document.createElement('textarea');
    textArea.innerHTML = encodedString;
    return textArea.value;
}

if (!String.prototype.endsWith) {
    String.prototype.endsWith = function(searchString, position) {
        var subjectString = this.toString();
        if (position === undefined || position > subjectString.length) {
            position = subjectString.length;
        }
        position -= searchString.length;
        var lastIndex = subjectString.indexOf(searchString, position);
        return lastIndex !== -1 && lastIndex === position;
    };
}

jQuery(document).ready(function($) {
    var docType = $('#poem').data('type');

    if(docType != undefined) {
        var props = docType.split('-');
        docSource = props[0];
        docStyle = props[1];
    }

    // Set initial stress to an empty string for all real spans
    var realSpans = $('span[real]');
    realSpans.attr('data-stress', '');

    var poemHeight = $('#poem').height();
    var rhymeHeight = poemHeight + 50;
    $('#rhymebar').height(rhymeHeight + 'px');
    $('#rhyme').height(rhymeHeight + 'px');

    var titleHeight = $('#poemtitle').height();
    var spacerHeight = titleHeight + 44;
    $('.rhymespacer').height(spacerHeight + 'px');

    // Set initial width of shadowsyllables
    setTimeout(function() {
        var shadowSyllables = $('.prosody-shadowsyllable');
        shadowSyllables.each(function(i) {
            var correspondingRealSyllable = $('#prosody-real-' + shadowSyllables[i].id.substring(15));
            var correspondingRealSyllableWidth = correspondingRealSyllable.innerWidth();
            shadowSyllables[i].style.width = correspondingRealSyllableWidth + 'px';

            var target = shadowSyllables[i].dataset.stress;
            if(target) {
                var arg = target.substr(1);

                var spacer = document.createElement('span');
                spacer.className = 'stress-spacer';
                spacer.textContent = ' ';
                switch(target[0]) {
                    case 'c':
                        var contents = correspondingRealSyllable[0].textContent;
                        var idx = correspondingRealSyllable[0].textContent.search(arg);
                        
                        correspondingRealSyllable[0].textContent = contents.substr(0, idx);
                        spacer.style.width = correspondingRealSyllable.innerWidth() + 'px';
                        correspondingRealSyllable[0].textContent = contents;
                    break;
                    case 'o':
                        spacer.style.width = correspondingRealSyllableWidth * (parseInt(arg)/100) + 'px';
                    break;
                }
                shadowSyllables[i].appendChild(spacer);
            }
        });
    }, 500);

    // Click handlers for toggles
    $('#togglestress').click(function() {
        togglestress(this);
    });
    $('#togglefeet').click(function() {
        togglefeet(this);
    });
    $('#togglecaesura').click(function() {
        togglecaesura(this);
    });
    $('#togglediscrepancies').click(function() {
        toggledifferences(this);
    });

    // Hide the syncopation checkbox
    $('#syncopation').hide();

    // Hide the Rhyme
    $('#rhyme').prev().hide();

    // initialize watch events to toggle the rhymebar
    $('.rhymefield').on('click', function() {
        $('#rhyme').toggle();
    });
    $('#rhymeflag').on('click', function() {
        $('#rhyme').toggle();
    });

    // watch for rhymeform submission and set scheme and answer
    $('#rhymeform').on('submit', function(event) {
        var scheme = $('#rhymeform').attr('name').replace(/\s/g, "");
        var ans = "";

        var total = $('#rhymeform :input[type=text]');
        $.each(total, function(index, object) {
            ans += object.value;
        });
        checkrhyme(scheme, ans);
        event.preventDefault();
    });

    // Dialog box for the meter
    $('#meter-select').dialog({ autoOpen: false });

    // Hide foot count selection in dolniks
    $('#foot-select').on('change', function(event) {
        var meter = event.target.value;

        if(meter == '+++' || meter == '++++') {
            $('#meter-select label[for^=number-select]').hide();
            $('#number-select').hide()
                [0].disabled = true;
        } else {
            $('#meter-select label[for^=number-select]').show();
            $('#number-select').show()
                [0].disabled = false;
        }
    });

    /* Populate the line state array with base correction states */
    $('.prosody-line').each(function(index) {
        lineStates[index] = {
            rhyme: false,
            meter: false,
            feet: false,
        };
    });

});

