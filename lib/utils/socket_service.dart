import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket _socket;

  void connect({required Function(Map data) onProgress}) {
    _socket = IO.io('http://localhost:5000', {
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.connect();

    _socket.onConnect((_) {
      print('🔌 Socket connected');
    });

    _socket.on('ocr_progress', (data) {
      print('📡 OCR progress: $data');
      onProgress(data);
    });

    _socket.onDisconnect((_) => print('🚫 Socket disconnected'));
  }

  void disconnect() {
    _socket.disconnect();
  }
}
