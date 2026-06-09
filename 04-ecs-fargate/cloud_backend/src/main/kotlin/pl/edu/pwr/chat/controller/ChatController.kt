package pl.edu.pwr.chat.controller

import org.springframework.format.annotation.DateTimeFormat
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import pl.edu.pwr.chat.dto.ImagePresignResponseTO
import pl.edu.pwr.chat.dto.MessageRequestTO
import pl.edu.pwr.chat.dto.MessagesListTO
import pl.edu.pwr.chat.service.ChatService
import java.time.LocalDateTime

@RestController
@RequestMapping("chat")
class ChatController(
    private val chatService: ChatService
) {

    @GetMapping("all")
    fun getAllMessages(@RequestParam username: String): ResponseEntity<MessagesListTO> =
        ResponseEntity.ok(chatService.getAllEvents(username))

    @GetMapping
    fun getNewMessages(
        @RequestParam username: String,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) after: LocalDateTime
    ): ResponseEntity<MessagesListTO> =
        ResponseEntity.ok(chatService.getNewMessages(username, after))

    @PostMapping
    fun createMessage(@RequestBody messageDTO: MessageRequestTO): ResponseEntity<Void> {
        chatService.createLiveEvent(messageDTO)
        return ResponseEntity.ok().build()
    }

    @GetMapping("/image/presign")
    fun getUploadPresignedUrl(@RequestParam filename: String): ResponseEntity<ImagePresignResponseTO> {
        val (uploadUrl, imageKey) = chatService.generateImageUploadUrl(filename)
        return ResponseEntity.ok(ImagePresignResponseTO(uploadUrl = uploadUrl, imageKey = imageKey))
    }

    @GetMapping("/image/{key}")
    fun getImageReadUrl(@PathVariable key: String): ResponseEntity<Map<String, String>> {
        val url = chatService.getImageReadUrl(key)
        return ResponseEntity.ok(mapOf("imageUrl" to url))
    }
}
