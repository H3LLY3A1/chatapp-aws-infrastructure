package pl.edu.pwr.chat.service

import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.s3.model.GetObjectRequest
import software.amazon.awssdk.services.s3.model.PutObjectRequest
import software.amazon.awssdk.services.s3.presigner.S3Presigner
import software.amazon.awssdk.services.s3.presigner.model.GetObjectPresignRequest
import software.amazon.awssdk.services.s3.presigner.model.PutObjectPresignRequest
import java.time.Duration
import java.util.UUID

@Service
class S3Service(
    @Value("\${aws.s3.bucket-name}") private val bucketName: String,
    @Value("\${aws.region}") private val awsRegion: String,
    @Value("\${aws.s3.presigned-url-expiration-minutes:60}") private val readExpirationMinutes: Long
) {
    private val presigner: S3Presigner = S3Presigner.builder()
        .region(Region.of(awsRegion))
        .build()

    fun generateUploadPresignedUrl(originalFilename: String): Pair<String, String> {
        val extension = originalFilename.substringAfterLast('.', "").ifEmpty { "bin" }
        val key = "${UUID.randomUUID()}.$extension"

        val presignRequest = PutObjectPresignRequest.builder()
            .signatureDuration(Duration.ofMinutes(15))
            .putObjectRequest(
                PutObjectRequest.builder()
                    .bucket(bucketName)
                    .key(key)
                    .build()
            )
            .build()

        val uploadUrl = presigner.presignPutObject(presignRequest).url().toString()
        return Pair(uploadUrl, key)
    }

    fun generateReadPresignedUrl(key: String): String {
        val presignRequest = GetObjectPresignRequest.builder()
            .signatureDuration(Duration.ofMinutes(readExpirationMinutes))
            .getObjectRequest(
                GetObjectRequest.builder()
                    .bucket(bucketName)
                    .key(key)
                    .build()
            )
            .build()

        return presigner.presignGetObject(presignRequest).url().toString()
    }
}
