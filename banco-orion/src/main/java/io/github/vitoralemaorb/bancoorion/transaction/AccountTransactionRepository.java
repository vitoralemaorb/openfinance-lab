package io.github.vitoralemaorb.bancoorion.transaction;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.UUID;

public interface AccountTransactionRepository extends JpaRepository<AccountTransaction, UUID> {

    Page<AccountTransaction> findByAccountIdAndBookedAtBetween(UUID accountId, Instant from, Instant to, Pageable pageable);
}
