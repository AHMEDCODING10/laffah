<?php

namespace App\Events;

use App\Models\Wallet;
use App\Models\Transaction;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Contracts\Events\ShouldDispatchAfterCommit;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class WalletBalanceUpdated implements ShouldBroadcast, ShouldDispatchAfterCommit
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public Wallet $wallet;
    public ?Transaction $transaction;
    public string $message;

    /**
     * Create a new event instance.
     */
    public function __construct(Wallet $wallet, ?Transaction $transaction = null, string $message = 'تم تحديث رصيد المحفظة')
    {
        $this->wallet = $wallet;
        $this->transaction = $transaction;
        $this->message = $message;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('user.' . $this->wallet->user_id),
            new Channel('wallet.' . $this->wallet->id),
        ];
    }

    /**
     * The event's broadcast name.
     */
    public function broadcastAs(): string
    {
        return 'WalletBalanceUpdated';
    }

    /**
     * Get the data to broadcast.
     */
    public function broadcastWith(): array
    {
        $available = max(0.0, (float) $this->wallet->balance - (float) ($this->wallet->held_balance ?? 0));

        return [
            'wallet_id'          => $this->wallet->id,
            'user_id'            => $this->wallet->user_id,
            'balance'            => (float) $this->wallet->balance,
            'held_balance'       => (float) ($this->wallet->held_balance ?? 0),
            'available_balance'  => $available,
            'currency'           => $this->wallet->currency ?? 'YER',
            'transaction_id'     => $this->transaction ? $this->transaction->id : null,
            'transaction_type'   => $this->transaction ? $this->transaction->type : null,
            'transaction_status' => $this->transaction ? $this->transaction->status : null,
            'amount'             => $this->transaction ? (float) $this->transaction->amount : null,
            'reference_id'       => $this->transaction ? $this->transaction->reference_id : null,
            'message'            => $this->message,
            'timestamp'          => now()->toIso8601String(),
        ];
    }
}
