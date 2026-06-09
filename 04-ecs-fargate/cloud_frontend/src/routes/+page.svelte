<script lang="ts">
	import { onMount, afterUpdate } from 'svelte';
	import axios from 'axios';
	import api from '$lib/api';
	import type { Message } from '$lib/types/Message';

	let username: string = 'User' + Math.floor(Math.random() * 1000);
	let newMessage: string = '';
	let messages: Message[] = [];
	let chatContainer: HTMLDivElement;
	let selectedFile: File | null = null;
	let fileInput: HTMLInputElement;
	let uploading = false;

	const scrollToBottom = () => {
		if (chatContainer) chatContainer.scrollTop = chatContainer.scrollHeight;
	};

	const fetchAllMessages = async () => {
		try {
			const response = await api.get('/chat/all', { params: { username } });
			messages = response.data.messages;
			scrollToBottom();
		} catch (error) {
			console.error('Error fetching all messages:', error);
		}
	};

	const fetchNewMessages = async () => {
		try {
			const lastTimestamp = messages.length
				? messages[messages.length - 1].timestamp
				: new Date(0).toISOString();
			const response = await api.get('/chat', { params: { username, after: lastTimestamp } });
			if (response.data.messages?.length) {
				messages = [...messages, ...response.data.messages];
				scrollToBottom();
			}
		} catch (error) {
			console.error('Error fetching new messages:', error);
		}
	};

	const sendMessage = async () => {
		if (!newMessage.trim() && !selectedFile) return;
		uploading = true; //blokuje przycisk
		try {
			let imageKey: string | undefined;

			if (selectedFile) {
				// Wariant 5.0
				const presignRes = await api.get('/chat/image/presign', {
					params: { filename: selectedFile.name }
				});
				const { uploadUrl, imageKey: key } = presignRes.data;

				await axios.put(uploadUrl, selectedFile, {
					headers: { 'Content-Type': selectedFile.type }
				});

				imageKey = key;
			}

			await api.post('/chat', {
				username,
				message: newMessage || '',
				imageKey
			});

			newMessage = '';
			selectedFile = null;
			if (fileInput) fileInput.value = '';
			await fetchAllMessages();
		} catch (error) {
			console.error('Error sending message:', error);
		} finally {
			uploading = false;
		}
	};

	const onFileChange = (e: Event) => { //zapis plik do zmiennej
		const input = e.target as HTMLInputElement;
		selectedFile = input.files?.[0] ?? null;
	};

	const handleKeydown = (e: KeyboardEvent) => {
		if (e.key === 'Enter' && !e.shiftKey) {
			e.preventDefault();
			sendMessage();
		}
	};

	onMount(() => {
		fetchAllMessages();
		const interval = setInterval(fetchNewMessages, 3000);
		return () => clearInterval(interval);
	});

	afterUpdate(scrollToBottom);
</script>

<div class="max-w-2xl mx-auto p-4">
	<div class="mb-4 flex items-center gap-2">
		<label for="username" class="font-semibold">Nickname:</label>
		<input
			id="username"
			type="text"
			autocomplete="off"
			bind:value={username}
			class="border border-gray-300 rounded px-3 py-2"
			placeholder="Enter your nickname"
		/>
	</div>

	<h1 class="text-2xl font-bold mb-4">Chat Room</h1>

	<div
		class="border border-gray-300 rounded p-4 mb-4 h-80 overflow-y-auto"
		bind:this={chatContainer}
	>
		{#each messages as msg (msg.timestamp)}
			<div class="mb-3">
				<div class="flex items-baseline gap-2">
					<span class="font-semibold">{msg.username}</span>
					<span class="text-sm text-gray-500">{new Date(msg.timestamp).toLocaleTimeString()}</span>
				</div>
				{#if msg.message}
					<p class="mt-0.5">{msg.message}</p>
				{/if}
				{#if msg.imageUrl}
					<img
						src={msg.imageUrl}
						alt="attachment"
						class="mt-1 max-h-60 rounded border border-gray-200 cursor-pointer"
						onclick={() => window.open(msg.imageUrl, '_blank')}
					/>
				{/if}
			</div>
		{/each}
	</div>

	{#if selectedFile}
		<div class="mb-2 flex items-center gap-2 text-sm text-gray-600">
			<span>📎 {selectedFile.name}</span>
			<button
				class="text-red-500 hover:text-red-700"
				onclick={() => {
					selectedFile = null;
					if (fileInput) fileInput.value = '';
				}}>✕</button
			>
		</div>
	{/if}

	<div class="flex gap-2">
		<label
			class="cursor-pointer flex items-center justify-center px-3 py-2 border border-gray-300 rounded hover:bg-gray-100"
			title="Dołącz obraz"
		>
			📎
			<input
				type="file"
				accept="image/*"
				class="hidden"
				bind:this={fileInput}
				onchange={onFileChange}
			/>
		</label>

		<input
			type="text"
			bind:value={newMessage}
			onkeydown={handleKeydown}
			class="flex-grow border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring"
			placeholder="Type your message..."
			disabled={uploading}
		/>

		<button
			onclick={sendMessage}
			disabled={uploading || (!newMessage.trim() && !selectedFile)}
			class="cursor-pointer bg-blue-500 hover:bg-blue-600 disabled:opacity-50 text-white font-semibold px-4 py-2 rounded"
		>
			{uploading ? '...' : 'Send'}
		</button>
	</div>
</div>
