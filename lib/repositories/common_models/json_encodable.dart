/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 15:18:49
 * @LastEditTime : 2022-10-11 15:22:13
 * @Description  : 
 */

abstract class JSONEncodable {
  const JSONEncodable();

  Map<String, Object?> get jsonObject;
}