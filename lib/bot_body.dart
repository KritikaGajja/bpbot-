import 'dart:convert';// Importing the 'dart:convert' library for JSON encoding and decoding.
import 'package:flutter/material.dart';// Importing the Flutter material library.
import 'package:http/http.dart' as http;// Importing the 'http' library for making HTTP requests.
import 'package:flutter_spinkit/flutter_spinkit.dart';// Importing a package for displaying loading spinners.


void main() {
  runApp(MaterialApp(
    home: ChatbotScreen(),// Setting the main application screen to be ChatbotScreen.
    theme: ThemeData(
      primaryColor: Colors.black, // Setting the primary color of the app to black.
      scaffoldBackgroundColor: Colors.black,// Setting the background color of the scaffold
      textTheme: TextTheme(
        bodyText2: TextStyle(color: Colors.white), // Setting text color to white
      ),
    ),
  ));
}

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  TextEditingController _messageController = TextEditingController();// Controller for the user's message input
  List<Message> _messages = [
    Message(
      text: "Hey! how MyBot can assist you?",
      isUserMessage: false,
    ),
  ]; // Initialize with the initial message
  bool _isLoading = false;
  final ScrollController _controller = ScrollController();

  void _scrollDown() {
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }

  Future<void> _sendMessage(String messageText) async {
    setState(() {
      _messages.add(Message(text: messageText, isUserMessage: true));
      _isLoading = true;
    });
    _scrollDown();

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer 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',
    };
    List<Map<String, dynamic>> messages = _messages.reversed.map((message) {
      return {
        'role': 'user',
        'content': messageText,
      };
    }).toList();
    Map<String, dynamic> params = {
      'model': 'gpt-3.5-turbo',
      'messages': messages,
      'temperature': 0.5,
      'max_tokens': 150,
    };
    var body = jsonEncode(params);
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      var choices = jsonResponse['choices'][0];
      var botResponse = choices['message']['content'];

      setState(() {
        _messages.add(Message(
          text: botResponse,
          isUserMessage: false,
        ));
        _isLoading = false;
      });
      _scrollDown();
      print('botResponse: $botResponse');
    } else {
      print('Request failed with status :${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MyBot Personal Assistant',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _controller,
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MessageBubble(
                  text: message.text,
                  isUserMessage: message.isUserMessage,
                );
              },
            ),
          ),
          BottomSheet(
            onClosing: () {},
            builder: (context) => Container(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'How MyBot can assist you today?',
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF011158)),
                        ),
                      ),
                      onSubmitted: (value) {
                        final messageText = _messageController.text;
                        if (messageText.isNotEmpty) {
                          _messageController.clear();
                          _sendMessage(messageText);
                        }
                      },
                      textInputAction: TextInputAction.done,
                      style: TextStyle(color: Color(0xFF011158)),
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.send,color: Color(0xFF011158),),
                        onPressed: () {
                          final messageText = _messageController.text;
                          if (messageText.isNotEmpty) {
                            _messageController.clear();
                            _sendMessage(messageText);
                          }
                        },
                      ),
                      if (_isLoading)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black54,
                            child: SpinKitThreeBounce(
                              color: Color(0xFF011158),
                              size: 20.0,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String text;
  final bool isUserMessage;

  Message({required this.text, required this.isUserMessage});
}

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUserMessage;

  MessageBubble({required this.text, required this.isUserMessage});

  @override
  Widget build(BuildContext context) {
    final bgColor = isUserMessage ? Colors.blue : Colors.grey[900];
    final textColor = isUserMessage ? Colors.white : Colors.white;
    final alignment = isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
