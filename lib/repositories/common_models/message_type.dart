/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 10:30:05
 * @LastEditTime : 2022-10-11 10:30:12
 * @Description  : 
 */

enum MessageType {
  plaintext('plaintext'),
  file('file'),
  image('image');

  factory MessageType.fromStringLiteral(String value) {
    return MessageType.values.firstWhere((element) => element._value == value);
  }
  const MessageType(String value): _value = value;
  final String _value;
  String get literal => _value;
}
