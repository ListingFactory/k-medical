import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../data/models/consultation.dart';

class ChatScreen extends StatefulWidget {
  final String consultationId;
  final String hospitalName;
  final String hospitalId;

  const ChatScreen({
    super.key,
    required this.consultationId,
    required this.hospitalName,
    required this.hospitalId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  
  List<File> _selectedImages = [];
  List<ConsultationMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  // 메시지 로드 (샘플 데이터)
  void _loadMessages() {
    _messages = [
      ConsultationMessage(
        id: '1',
        consultationId: widget.consultationId,
        senderId: 'hospital',
        senderName: widget.hospitalName,
        senderRole: 'hospital',
        content: '안녕하세요! 상담 요청을 받았습니다. 더 자세한 상담을 위해 몇 가지 질문을 드리겠습니다.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ConsultationMessage(
        id: '2',
        consultationId: widget.consultationId,
        senderId: 'user',
        senderName: '사용자',
        senderRole: 'user',
        content: '네, 상담 부탁드립니다.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  // 사진 촬영
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null) {
        setState(() {
          _selectedImages.add(File(photo.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 촬영 중 오류가 발생했습니다: $e')),
      );
    }
  }

  // 갤러리에서 사진 선택
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 선택 중 오류가 발생했습니다: $e')),
      );
    }
  }

  // 링크 추가
  void _addLink() {
    if (_linkController.text.trim().isNotEmpty) {
      setState(() {
        _selectedImages.add(File(_linkController.text.trim()));
      });
      _linkController.clear();
    }
  }

  // 메시지 전송
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty && _selectedImages.isEmpty) {
      return;
    }

    final message = ConsultationMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      consultationId: widget.consultationId,
      senderId: 'user',
      senderName: '사용자',
      senderRole: 'user',
      content: _messageController.text.trim(),
      imageUrls: _selectedImages.map((file) => file.path).toList(),
      links: _selectedImages.where((file) => file.path.startsWith('http')).map((file) => file.path).toList(),
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(message);
      _messageController.clear();
      _selectedImages.clear();
    });

    // 스크롤을 맨 아래로
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 플랫폼별 이미지 표시 위젯
  Widget _buildImageWidget(String imagePath, {double width = 100, double height = 100}) {
    if (kIsWeb) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.image,
          color: Colors.grey,
          size: 32,
        ),
      );
    } else {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(imagePath),
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: width,
                height: height,
                color: Colors.grey.shade300,
                child: const Icon(
                  Icons.error,
                  color: Colors.grey,
                ),
              );
            },
          ),
        );
      } catch (e) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade300,
          child: const Icon(
            Icons.error,
            color: Colors.grey,
          ),
        );
      }
    }
  }

  // 링크 표시 위젯
  Widget _buildLinkWidget(String link) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link, color: Colors.blue, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              link,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.hospitalName}와의 상담'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 메시지 목록
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.senderRole == 'user';
                
                return _buildMessageBubble(message, isUser);
              },
            ),
          ),
          
          // 입력 영역
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              children: [
                // 선택된 이미지들 표시
                if (_selectedImages.isNotEmpty) ...[
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              _buildImageWidget(_selectedImages[index].path, width: 80, height: 80),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // 입력 필드와 버튼들
                Row(
                  children: [
                    // 사진 촬영 버튼
                    IconButton(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      color: Colors.grey.shade600,
                    ),
                    
                    // 갤러리 버튼
                    IconButton(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      color: Colors.grey.shade600,
                    ),
                    
                    // 링크 추가 버튼
                    IconButton(
                      onPressed: () => _showLinkDialog(),
                      icon: const Icon(Icons.link),
                      color: Colors.grey.shade600,
                    ),
                    
                    // 메시지 입력 필드
                    Expanded(
                      child: Container(
                        height: 120,
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: '메시지를 입력하세요...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            contentPadding: EdgeInsets.all(16),
                            alignLabelWithHint: true,
                          ),
                          maxLines: null,
                          expands: true,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // 전송 버튼
                    FloatingActionButton(
                      onPressed: _sendMessage,
                      backgroundColor: AppColors.primary,
                      mini: true,
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 메시지 버블 생성
  Widget _buildMessageBubble(ConsultationMessage message, bool isUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text(
                message.senderName.isNotEmpty ? message.senderName[0] : 'H',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 발신자 이름
                  if (!isUser)
                    Text(
                      message.senderName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  
                  if (!isUser) const SizedBox(height: 4),
                  
                  // 메시지 내용
                  if (message.content.isNotEmpty)
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  
                  // 이미지들
                  if (message.imageUrls.isNotEmpty) ...[
                    if (message.content.isNotEmpty) const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: message.imageUrls.map((imageUrl) => 
                        _buildImageWidget(imageUrl, width: 120, height: 120)
                      ).toList(),
                    ),
                  ],
                  
                  // 링크들
                  if (message.links.isNotEmpty) ...[
                    if (message.content.isNotEmpty || message.imageUrls.isNotEmpty) 
                      const SizedBox(height: 8),
                    ...message.links.map((link) => _buildLinkWidget(link)),
                  ],
                  
                  // 시간
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: isUser ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 링크 추가 다이얼로그
  void _showLinkDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('링크 추가'),
        content: Container(
          height: 100,
          child: TextField(
            controller: _linkController,
            decoration: const InputDecoration(
              labelText: '링크 URL',
              hintText: 'https://example.com',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(16),
            ),
            keyboardType: TextInputType.url,
            maxLines: null,
            expands: true,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_linkController.text.trim().isNotEmpty) {
                setState(() {
                  _selectedImages.add(File(_linkController.text.trim()));
                });
                _linkController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  // 정보 다이얼로그
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('상담 안내'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📋 상담 진행 방법'),
            SizedBox(height: 8),
            Text('• 사진, 링크, 텍스트를 자유롭게 첨부할 수 있습니다'),
            Text('• 병원과 실시간으로 소통하며 상담을 진행합니다'),
            Text('• 약속 일정, 치료 방법 등을 상세히 안내받을 수 있습니다'),
            SizedBox(height: 16),
            Text('💡 팁'),
            SizedBox(height: 8),
            Text('• 명확한 증상을 설명하면 더 정확한 상담이 가능합니다'),
            Text('• 관련 사진을 첨부하면 진단에 도움이 됩니다'),
            Text('• 궁금한 점은 언제든 질문하세요'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _linkController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
