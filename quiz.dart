import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ansicolor/ansicolor.dart';
import 'package:interact/interact.dart';
import 'package:html_unescape/html_unescape.dart';

void main() async {
  askQuestion(true);
}

void askQuestion([bool infinite = false]) async {
  var unescape = HtmlUnescape();
  AnsiPen bluePen = new AnsiPen()
    ..blue(
      bold: true,
    );
  AnsiPen redPen = new AnsiPen()
    ..red(
      bold: true,
    );
  AnsiPen cyanPen = new AnsiPen()
    ..cyan(
      bold: true,
    );
  AnsiPen greenPen = new AnsiPen()..green(bold: true);
  AnsiPen yellowPen = new AnsiPen()
    ..yellow(
      bold: true,
    );

  final Uri reqUri = Uri.parse(
      "https://opentdb.com/api.php?amount=1&difficulty=easy&type=multiple");

  try {
    print(cyanPen("-----------------------------------------------------"));

    final spinners = MultiSpinner();
    final loading = spinners.add(Spinner(
      icon: '✅',
      rightPrompt: (done) =>
          done ? 'Question loaded successfully!' : 'Question loading...',
    ));

    var responseData = await http.get(reqUri);
    loading.done();
    var decodedData = json.decode(responseData.body);
    var question = decodedData['results'][0]['question'];

    var correctAnswer = decodedData["results"][0]["correct_answer"];
    var incorrectAnswers = decodedData["results"][0]["incorrect_answers"];

    List<String> allOptions = [...incorrectAnswers, correctAnswer];
    allOptions = allOptions.map(unescape.convert).toList();
    print(allOptions);
    allOptions.shuffle();

    final selection = Select(
      prompt: unescape.convert(question) +
          " (${decodedData['results'][0]['category']})",
      options: allOptions,
    ).interact();
    bool isUserAnsCorrect = allOptions[selection] == correctAnswer;
    print(isUserAnsCorrect
        ? greenPen("----\n✔ Correct!\n----")
        : redPen("----\n✖ Incorrect!\n----"));

    print(isUserAnsCorrect
        ? bluePen("The correct answer is: $correctAnswer")
        : yellowPen("The correct answer is: $correctAnswer"));

    print(cyanPen("-----------------------------------------------------"));

    if (infinite) {
      print('\n\n');
      askQuestion(infinite);
    }
  } catch (e) {
    print(e);
  }
}
