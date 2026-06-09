package pl.edu.pwr.chat.service

import org.springframework.stereotype.Service
import pl.edu.pwr.chat.dto.MessageRequestTO
import pl.edu.pwr.chat.dto.MessageTO
import pl.edu.pwr.chat.dto.MessagesListTO
import pl.edu.pwr.chat.model.ChatMessage
import pl.edu.pwr.chat.repository.ChatMessageRepository
import java.time.LocalDateTime

@Service
class ChatServiceImpl(
    private val chatMessageRepository: ChatMessageRepository,
    private val s3Service: S3Service
) : ChatService {

    override fun getAllEvents(username: String): MessagesListTO {
        val messages = chatMessageRepository.findAll()
        return MessagesListTO(messages = messages.map { it.toTO() })
    }

    override fun getNewMessages(username: String, after: LocalDateTime): MessagesListTO {
        val messages = chatMessageRepository.findByTimestampAfter(after)
        return MessagesListTO(messages = messages.map { it.toTO() })
    }

    override fun createLiveEvent(messageDTO: MessageRequestTO) {
        chatMessageRepository.save(
            ChatMessage(
                username = messageDTO.username,
                message = messageDTO.message,
                timestamp = LocalDateTime.now(),
                imageKey = messageDTO.imageKey
            )
        )
    }

    override fun generateImageUploadUrl(filename: String): Pair<String, String> =
        s3Service.generateUploadPresignedUrl(filename)

    override fun getImageReadUrl(key: String): String =
        s3Service.generateReadPresignedUrl(key)

    private fun ChatMessage.toTO() = MessageTO(
        username = username,
        message = message,
        timestamp = timestamp,
        imageUrl = imageKey?.let { s3Service.generateReadPresignedUrl(it) }
    )
}
